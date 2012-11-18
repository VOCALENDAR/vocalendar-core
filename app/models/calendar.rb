class Calendar < ActiveRecord::Base
  include VocalendarCore::ModelLogUtils
  default_scope order('io_type desc, name')

  has_many :fetched_events, :class_name => 'Event',
    :foreign_key => 'g_calendar_id', :primary_key => 'external_id'
  has_and_belongs_to_many :tags
  has_many :target_events, :through => :tags, :source => :events
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
    self.tag_names_append_str.to_s.strip.split(%r{(?:\s|/)+})
  end

  def tag_names_append=(v)
    self.tag_names_append_str = v.join(' ')
  end

  def tag_names_remove
    self.tag_names_remove_str.to_s.strip.split(%r{(?:\s|/)+})
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
    opts = {:force => false, :max => 2000}.merge opts
    log :info, "Start event publish"
    count = 0

    self.update_attribute :sync_started_at, DateTime.now

    target_events = self.target_events.reorder('events.updated_at')
    self.latest_synced_item_updated_at && !opts[:force] and
      target_events = target_events.where('events.updated_at >= ?', self.latest_synced_item_updated_at)

    begin
      last_event_updated_at = nil
      target_events.each do |event|
        if event.g_calendar_id.blank? || event.ical_uid.blank?
          log :error, "Sync skip! Event ##{event.id} don't have g_calendar_id & event.ical_uid"
          next
        end
        body = event.to_exfmt :google_v3,
          :tag_names_append => self.tag_names_append,
          :tag_names_remove => self.tag_names_remove
        result = gapi_request :import, {}, body.to_json
        count += 1
        last_event_updated_at = event.updated_at
        log :info, "Event '#{event.summary}' (##{event.id}) has been published successfully."
        count >= opts[:max] and break
      end
    ensure
      self.update_attribute :latest_synced_item_updated_at, last_event_updated_at
    end

    self.update_attribute :sync_finished_at, DateTime.now
    log :info, "Event publish completed. #{count} events has been updated (#{DateTime.now.to_f - self.sync_started_at.to_f} secs)."
  end

  def cleanup_published_events(opts = {})
    log :info, "Start published event cleanup"
    start_time = DateTime.now.to_f
    remote_eids = []
    self.gapi_list_each_page(:showDeleted => false) do |result|
      result.data["items"] or break
      remote_eids += result.data.items.map { |e| e.id }
    end
    local_eids = []
    target_events.each do |e|
      e.g_id.blank? and next
      local_eids << e.g_id
    end
    delete_eids = remote_eids - local_eids
    delete_eids.each do |eid|
      log :info, "Delete event: google event ID=#{eid}"
      gapi_request :delete, {:eventId => eid}
    end
    log :info, "Event cleanup completed: #{delete_eids.size} events has been deleted (#{DateTime.now.to_f - start_time} secs)"
  end

  def fetch_events(opts = {})
    opts = {:force => false, :max => 2000}.merge opts
    log :info, "Start event sync"
    count = 0
    default_tz_min = (Time.now.to_datetime.offset * 60 * 24).to_i

    self.update_attribute :sync_started_at, DateTime.now

    query_params = {}
    if !opts[:force] && self.latest_synced_item_updated_at &&
        self.latest_synced_item_updated_at > (DateTime.now - 20.days)
      # Google limit updatedMin to 20 days. Drop the parameter if it's over 20 days to avoid error.
      query_params[:updatedMin] = self.latest_synced_item_updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

    self.gapi_list_each_page(query_params) do |result|
      default_tz_min = TZInfo::Timezone.get(result.data.timeZone).current_period.utc_offset / 60

      result.data["items"] or break
<<<<<<< HEAD

      begin
        new_item_stamp = nil
        result.data.items.each do |eitem|
          event = Event.find_by_g_id(eitem.id) || Event.new
          begin
            event.load_exfmt :google_v3, eitem,
              :calendar_id => self.external_id, :default_tz_min => default_tz_min,
              :tag_names_append => self.tag_names_append,
              :tag_names_remove => self.tag_names_remove
            log :info, "Event sync: #{event.new_record? ? "create new event" : "update event ##{event.id}"}: #{event.summary}"
            begin
              event.save!
            rescue ActiveRecord::RecordInvalid => e
              log :error, "Failed to save with validation: #{e.message} on #{eitem["htmlLink"]}"
              event.save :validate => false
            end
            count += 1
            new_item_stamp = eitem["updated"]
            opts[:max] <= count and break
          rescue => e
            log :error, "Failed to sync event: #{e.class.name}: #{e.to_s} (#{e.backtrace.join(' > ')})"
            log :error, "Failed item: #{eitem.inspect}"
            raise e
          end
=======
      result.data.items.each do |eitem|
        event = Event.find_by_g_id(eitem.id) || Event.new
        begin
          event.load_exfmt :google_v3, eitem,
            :calendar_id => self.external_id, :default_tz_min => default_tz_min,
            :tag_names_append => self.tag_names_append,
            :tag_names_remove => self.tag_names_remove
          log :info, "Event sync: #{event.new_record? ? "create new event" : "update event ##{event.id}"}: #{event.summary}"
          begin
            event.save!
          rescue ActiveRecord::RecordInvalid => e
            log :error, "Failed to save with validation: #{e.message} on #{eitem["htmlLink"]}"
            event.save :validate => false
          end
          count += 1
          self.update_attribute :latest_synced_item_updated_at, eitem["updated"]
          opts[:max] <= count and break
        rescue => e
          log :error, "Failed to sync event: #{e.class.name}: #{e.to_s} (#{e.backtrace.join(' > ')})"
          log :error, "Failed item: #{eitem.inspect}"
          raise e
>>>>>>> 885b41e04a885371d439e3a4323821725b54d950
        end
      ensure
        new_item_stamp and
          self.update_attribute :latest_synced_item_updated_at, new_item_stamp
      end
    end

    self.update_attribute :sync_finished_at, DateTime.now
    log :info, "Event sync completed: #{count} events has been updated (#{DateTime.now.to_f - self.sync_started_at.to_f} secs)."
  end

  def gapi_list_each_page(params = {}, &block)
    params = {
      :singleEvents => false,
      :showDeleted => true,
      :orderBy => 'updated',
    }.merge(params)

    while true
      log :debug, "Getting event list via Google API: #{params.inspect}"
      result = gapi_request :list, params
      yield result
      result.next_page_token or break
      params[:pageToken] = result.next_page_token
    end
  end

  def gapi_request(method, params = {}, body = nil)
    assert_user_gauth
    user.gapi_request("events.#{method}", {:calendarId => self.external_id}.merge(params), body)
  end

  private
  def trim_attrs
    self[:name].strip!
    self[:external_id].strip!
    self[:io_type].strip!
    self[:tag_names_append_str].try(:strip!)
    self[:tag_names_remove_str].try(:strip!)
  end

  def assert_user_gauth
    msg = nil
    self.user or
      msg = "Calendar has no owner! Skip publish."
    self.user && !self.user.google_auth_valid? and
      msg = "Calendar owner ##{self.user.id} has no valid google auth information! Skip publish."
    msg or return true
    log :error, msg
    raise VocalendarCore::CalendarSyncError.new(msg)
  end
end

