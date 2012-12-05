# -*- coding: utf-8 -*-
class Calendar < ActiveRecord::Base
  include VocalendarCore::ModelLogUtils
  include VocalendarCore::HistoryUtils::Model

  default_scope order('io_type desc, name')

  has_many :fetched_events, :class_name => 'Event',
    :foreign_key => 'g_calendar_id', :primary_key => 'external_id'
  has_many :target_events, :through => :tags, :source => :events
  has_many :histories, :class_name => 'History',
    :conditions => {:target => 'calendar'}, :foreign_key => 'target_id'
  has_and_belongs_to_many :tags
  belongs_to :user

  basic_allowed_attrs = [:name, :external_id, :io_type, :tag_ids,
                         :tag_names_append_str,
                         :tag_names_remove_str]
  attr_accessible *basic_allowed_attrs
  attr_accessible *(basic_allowed_attrs + [:user_id]), :as => :admin

  validates :name, :presence => true
  validates :external_id, :presence => true, :uniqueness => true
  validates :io_type, :presence => true, :inclusion => {:in => %w(src dst)}

  before_validation :trim_attrs

  def tag_names_append
    tag_names_append_str.to_s.strip.split(VocalendarCore::TagSeparateRegexp)
  end

  def tag_names_append=(v)
    self.tag_names_append_str = v.join(' ')
  end

  def tag_names_remove
    tag_names_remove_str.to_s.strip.split(VocalendarCore::TagSeparateRegexp)
  end

  def tag_names_remove=(v)
    self.tag_names_remove_str = v.join(' ')
  end

  def sync_events(opts = {})
    if io_type == 'dst'
      publish_events opts
      cleanup_published_events opts
    elsif io_type == 'src'
      fetch_events opts
    end
  end

  def publish_events(opts = {})
    lock do
      publish_events_without_lock(opts)
    end
  end

  def publish_events_without_lock(opts = {})
    opts = {:force => false, :max => 2000}.merge opts
    log :info, "Start event publish"

    target_events = self.target_events.reorder('events.updated_at')
    latest_synced_item_updated_at && !opts[:force] and
      target_events = target_events.where('events.updated_at >= ?', latest_synced_item_updated_at)

    count = 0
    count_fail  = 0
    count_total = target_events.length

    update_attribute :sync_started_at, DateTime.now
    add_history :action => 'publish_started', :note => "Target are #{count_total} events."

    begin
      last_event_updated_at = nil
      target_events.each do |event|
        if event.g_calendar_id.blank? || event.ical_uid.blank?
          log :error, "Sync skip! Event ##{event.id} don't have g_calendar_id & event.ical_uid"
          next
        end
        begin
          body = event.to_exfmt :google_v3,
            :tag_names_append => tag_names_append,
            :tag_names_remove => tag_names_remove
          result = gapi_event_request :import, {}, body.to_json

	  # Note: timeZone cannot be set by import?
	  # To make sure, call patch request to force to update timezone.
	  if !event.allday? && result.data.start["timeZone"] != event.timezone.try(:name)
	    patch_ret = gapi_event_request :patch, {:eventId => result.data.id}, body.to_json
	  end

          count += 1
          last_event_updated_at = event.updated_at
          log :info, "(#{count+count_fail}/#{count_total}) Event '#{event.summary}' (##{event.id}) has been published successfully."
          add_history(:target    => 'event',
                      :target_id => event.id,
                      :action    => 'published',
                      :note      => "To calendar##{id} #{name} (remote event ID: #{result.data.id})")
          count >= opts[:max] and break
        rescue VocalendarCore::GoogleAPIError => e
	  count_fail += 1
	  extra_msg = ""
	  e.message.include?("Invalid Value") and
	    extra_msg = " (may try to update cancelled event)"
          log :error, "(#{count+count_fail}/#{count_total}) Failed to publish event ##{event.id} (#{event.name}): #{e.message}#{extra_msg}"
          add_history(:target    => 'event',
                      :target_id => event.id,
                      :action    => 'publish_failed',
                      :note      => "[calendar##{id} (#{name})] #{e.message}#{extra_msg}")
          event.updated_at_will_change!
          event.save! # force update timestamp to try publish again on next cycle

	  e.message.include?("Quota Exceeded") && e.api_result.status == 403 and
	    raise VocalendarCore::CalendarSyncError.new("Google API over quota. Calendar sync aborted.")
        end
      end
    ensure
      last_event_updated_at and
	update_attribute :latest_synced_item_updated_at, last_event_updated_at
    end

    update_attribute :sync_finished_at, DateTime.now
    msg = "#{count} events has been updated #{count_fail > 0 ? "(#{count_fail} events failed) " : ""}(#{DateTime.now.to_f - sync_started_at.to_f} secs)."
    log :info, "Event publish completed. #{msg}"
    add_history :action => 'publish_finished', :note => msg
  end

  def cleanup_published_events(opts = {})
    log :info, "Start published event cleanup"
    start_time = DateTime.now.to_f
    remote_gids = []
    gapi_list_each_page(:showDeleted => false) do |result|
      result.data["items"] or break
      remote_gids += result.data.items.map { |e| e.id }
    end
    local_gids = []
    target_events.each do |e|
      e.g_id.blank? and next
      local_gids << e.g_id
    end
    delete_gids = remote_gids - local_gids
    delete_gids.each do |gid|
      log :info, "Delete event: google event ID=#{gid}"
      gapi_event_request :delete, {:eventId => gid}
      add_history(:target    => 'event',
                  :target_id => Event.find_by_g_id(gid).try(:id),
                  :action    => 'delete_from_google',
                  :note      => "From calenar##{id} (#{name})")
    end
    log :info, "Event cleanup completed: #{delete_gids.size} events has been deleted (#{DateTime.now.to_f - start_time} secs)"
  end

  def fetch_events(opts = {})
    lock do
      fetch_events_without_lock(opts)
    end
  end

  def fetch_events_without_lock(opts = {})
    opts = {:force => false, :max => 2000}.merge opts
    log :info, "Start event sync"
    count = 0
    add_history :action => :fetch_started
    update_attribute :sync_started_at, DateTime.now

    query_params = {}
    if !opts[:force] && latest_synced_item_updated_at &&
        latest_synced_item_updated_at > (DateTime.now - 20.days)
      # Google limit updatedMin to 20 days. Drop the parameter if it's over 20 days to avoid error.
      query_params[:updatedMin] = latest_synced_item_updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

    gapi_list_each_page(query_params) do |result|
      default_timezone = result.data.timeZone

      result.data["items"] or break

      begin
        new_item_stamp = nil
        result.data.items.each do |eitem|
          event = Event.find_by_g_id(eitem.id) || Event.new
          begin
            event.load_exfmt :google_v3, eitem,
              :calendar_id      => external_id,
              :default_timezone => default_timezone,
              :tag_names_append => tag_names_append,
              :tag_names_remove => tag_names_remove
            log :info, "Event sync: #{event.new_record? ? "create new event" : "update event ##{event.id}"}: #{event.summary}"
            begin
              event.save!
            rescue ActiveRecord::RecordInvalid => e
              log :error, "Failed to save with validation: #{e.message} on #{eitem["htmlLink"]}"
              event.save :validate => false
            end
            count += 1
            new_item_stamp = eitem["updated"]
            add_history(:target    => 'event',
                        :target_id => event.id,
                        :action    => 'import_from_google',
                        :note      => "From calendar##{id} (#{name})")
            opts[:max] <= count and break
          rescue => e
            log :error, "Failed to sync event: #{e.class.name}: #{e.to_s} (#{e.backtrace.join(' > ')})"
            log :error, "Failed item: #{eitem.inspect}"
            raise e
          end
        end
      ensure
        new_item_stamp and
          update_attribute :latest_synced_item_updated_at, new_item_stamp
      end
    end

    update_attribute :sync_finished_at, DateTime.now
    log :info, "Event sync completed: #{count} events has been updated (#{DateTime.now.to_f - sync_started_at.to_f} secs)."
    add_history :action => :fetch_finished
  end

  def compare_remote_events(another)
    all_events = Hash.new{|h,k| h[k] = {}}
    [self, another].each do |cal|
      cal.gapi_list_each_page do |result|
        result.data.items.each do |eitem|
          e = eitem.to_hash
          %w(created updated creator organizer attendees
             extendedProperties reminders visibility
             transparency sequence etag htmlLink).each do |attr|
            e.delete attr
          end
          e["summary"] = e["summary"] = e["summary"].to_s.gsub(/(】|★)\s*/, '\1').strip
          e["status"] == "tentative" and e["status"] = "confirmed"
          all_events[cal][eitem["id"]] = e
        end
      end
    end

    my_events = all_events[self]
    op_events = all_events[another]

    diff = {
      :a       => my_events,
      :b       => op_events,
      :added   => (op_events.keys - my_events.keys).map {|id| op_events[id]},
      :deleted => (my_events.keys - op_events.keys).map {|id| my_events[id]},
    }
    c = diff[:changed] = {}
    (my_events.keys & op_events.keys).each do |id|
      d = my_events[id].diff(op_events[id])
      d.empty? and next
      c[id] = Hash[*d.keys.map {|k|
                      [k, [my_events[id][k], op_events[id][k]]]
                    }.flatten(1)]
    end
    diff
  end

  def gapi_list_each_page(params = {}, &block)
    params = {
      :singleEvents => false,
      :showDeleted => true,
      :orderBy => 'updated',
    }.merge(params)

    while true
      log :debug, "Getting event list via Google API: #{params.inspect}"
      result = gapi_event_request :list, params
      yield result
      result.next_page_token or break
      params[:pageToken] = result.next_page_token
    end
  end

  def gapi_event_request(method, params = {}, body = nil)
    gapi_request("events.#{method}", params, body)
  end

  def gapi_request(method, params = {}, body = nil)
    assert_user_gauth
    user.gapi_request(method, {:calendarId => external_id}.merge(params), body)
  end

  private
  def lockfile_path
    require 'tmpdir'
    "#{Dir.tmpdir}/vc-calendar-sync_#{id}.lock"
  end

  def lock
    mode = File::LOCK_EX | File::LOCK_NB
    failmsg = "Can't get lock for calendar##{id}."
    if block_given?
      open(lockfile_path, "w") do |f|
        f.flock mode or
          raise VocalendarCore::CalendarSyncError.new(failmsg)
        yield
      end
    else
      @lock_fh = open(lockfile_path, "w")
      @lock_fh.flock mode or 
        raise VocalendarCore::CalendarSyncError.new(failmsg)
    end
  end

  def unlock
    @lock_fh.try(:close) rescue IOError
  end

  def trim_attrs
    self[:name].strip!
    self[:external_id].strip!
    self[:io_type].strip!
    self[:tag_names_append_str].try(:strip!)
    self[:tag_names_remove_str].try(:strip!)
  end

  def assert_user_gauth
    msg = nil
    user or
      msg = "Calendar has no owner! Can not exec Google API request."
    user && !user.google_auth_valid? and
      msg = "Calendar owner ##{user.id} has no valid google auth information! Can not exec Google API request."
    msg or return true
    log :error, msg
    raise VocalendarCore::CalendarSyncError.new(msg)
  end
end
