class Calendar < ActiveRecord::Base
  include VocalendarCore::Utils
  default_scope order('io_type desc, name')

  has_many :fetched_events, :class_name => 'Event',
    :foreign_key => 'g_calendar_id', :primary_key => 'external_id'
  has_and_belongs_to_many :tags
  has_many :target_events, :through => :tags, :source => :events

  attr_accessible :name, :external_id, :io_type, :sync_started_at,
    :sync_finished_at, :latest_synced_item_updated_at, :tag_ids,
    :tag_names_append_str, :tag_names_remove_str

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
    logger.info "Start event publish for calendar '#{name}' (##{id})"
    count = 0

    self.update_attributes! :sync_started_at => DateTime.now

    target_events = self.target_events.reorder('events.updated_at')
    self.latest_synced_item_updated_at && !opts[:force] and
      target_events = target_events.where('events.updated_at >= ?', self.latest_synced_item_updated_at)

    target_events.each do |event|
      if event.g_calendar_id.blank? || event.ical_uid.blank?
        logger.error "Sync skip! Event ##{event.id} don't have g_calendar_id & event.ical_uid"
        next
      end
      body = event.to_exfmt :google_v3,
        :tag_names_append => self.tag_names_append,
        :tag_names_remove => self.tag_names_remove
      result = gapi_request :import, {}, body.to_json
      count += 1
      self.update_attributes! :latest_synced_item_updated_at => event.updated_at
      logger.info "Event '#{event.summary}' (##{event.id}) has been published to calendar '#{self.name}' (##{self.id}) successfully."
      count >= opts[:max] and break
    end

    self.update_attributes! :sync_finished_at => DateTime.now
    logger.info "Event publish completed for calendar '#{name}' (##{id}): #{count} events has been updated (#{DateTime.now.to_f - self.sync_started_at.to_f} secs)."
  end

  def cleanup_published_events(opts = {})
    logger.info "Start published event cleanup for calendar '#{name}' (##{id})"
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
      logger.info "Delete event from calendar '#{self.name}' (##{self.id}): google event ID=#{eid}"
      gapi_request :delete, {:eventId => eid}
    end
    logger.info "Event cleanup completed: #{delete_eids.size} events has been deleted (#{DateTime.now.to_f - start_time} secs)"
  end

  def fetch_events(opts = {})
    opts = {:force => false, :max => 2000}.merge opts
    logger.info "Start event sync for calendar '#{name}' (##{id})"
    count = 0
    default_tz_min = (Time.now.to_datetime.offset * 60 * 24).to_i

    self.update_attributes! :sync_started_at => DateTime.now

    query_params = {}
    self.latest_synced_item_updated_at && !opts[:force] and
      query_params[:updatedMin] = (self.latest_synced_item_updated_at - 5.minute).utc.strftime("%Y-%m-%dT%H:%M:%SZ")

    self.gapi_list_each_page(query_params) do |result|
      default_tz_min = TZInfo::Timezone.get(result.data.timeZone).current_period.utc_offset / 60

      result.data["items"] or break
      result.data.items.each do |eitem|
        event = Event.find_by_g_id(eitem.id) || Event.new
        begin
          event.load_exfmt :google_v3, eitem,
            :calendar_id => self.external_id, :default_tz_min => default_tz_min,
            :tag_names_append => self.tag_names_append,
            :tag_names_remove => self.tag_names_remove
          logger.info "Event sync: #{event.new_record? ? "create new event" : "update event ##{event.id}"}: #{event.summary}"
          begin
            event.save!
          rescue ActiveRecord::RecordInvalid => e
            logger.error "Failed to save with validation: #{e.message} on #{eitem["htmlLink"]}"
            event.save :validate => false
          end
          count += 1
          self.update_attributes! :latest_synced_item_updated_at => eitem["updated"]
          opts[:max] <= count and break
        rescue => e
          logger.error "Failed to sync event: #{e.class.name}: #{e.to_s} (#{e.backtrace.join(' > ')})"
          logger.error "Failed item: #{eitem.inspect}"
          raise e
        end
      end
    end

    self.update_attributes! :sync_finished_at => DateTime.now
    logger.info "Event sync completed for calendar '#{name}' (##{id}): #{count} events has been updated (#{DateTime.now.to_f - self.sync_started_at.to_f} secs)."
  end

  def gapi_list_each_page(params = {}, &block)
    params = {
      :singleEvents => false,
      :showDeleted => true,
      :orderBy => 'updated',
    }.merge(params)

    while true
      logger.debug "Getting event list via Google API: #{params.inspect}"
      result = gapi_request :list, params
      yield result
      result.next_page_token or break
      params[:pageToken] = result.next_page_token
    end
  end

  alias_method :_gapi_request, :gapi_request
  def gapi_request(method, params = {}, body = nil)
    _gapi_request(method, {:calendarId => self.external_id}.merge(params), body)
  end

  private
  def trim_attrs
    self[:name].strip!
    self[:external_id].strip!
    self[:io_type].strip!
    self[:tag_names_append_str].try(:strip!)
    self[:tag_names_remove_str].try(:strip!)
  end
end

