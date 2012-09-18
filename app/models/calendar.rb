# -*- encoding: utf-8 -*-
class Calendar < ActiveRecord::Base
  include VocalendarCore::Utils
  default_scope order('io_type desc, name')

  has_many :fetched_events, :class_name => 'Event', :foreign_key => 'g_calendar_id', :primary_key => 'external_id'
  has_and_belongs_to_many :tags
  has_many :target_events, :through => :tags, :source => :events

  attr_accessible :name, :external_id, :io_type, :sync_started_at, :sync_finished_at, :latest_synced_item_updated_at, :tag_ids

  validates :name, :presence => true
  validates :external_id, :presence => true, :uniqueness => true
  validates :io_type, :presence => true, :inclusion => {:in => %w(src dst)}

  before_validation :trim_attrs

  def sync_events(opts = {})
    io_type == 'dst' and publish_events(opts)
    io_type == 'src' and fetch_events(opts)
  end

  def publish_events(opts = {})
    opts = {:force => false, :max => 2000}.merge opts
    logger.info "Start event sync for calendar '#{name}' (##{id})"
    count = 0

    self.update_attributes! :sync_started_at => DateTime.now

    client = gapi_client
    service = client.discovered_api('calendar', 'v3')

    params = {
      :headers => {'Content-Type' => 'application/json'},
      :api_method => service.events.import,
      :parameters => {
        :calendarId => self.external_id,
      }
    }

    target_events = self.target_events.reorder('events.updated_at')
    self.latest_synced_item_updated_at && !opts[:force] and
      target_events = target_events.where('events.updated_at >= ?', self.latest_synced_item_updated_at)

    target_events.each do |event|
      if event.g_calendar_id.blank? || event.ical_uid.blank?
        logger.error "Sync skip! Event ##{event.id} don't have g_calendar_id & event.ical_uid"
        next
      end
      params[:body] = event.to_exfmt(:google_v3).to_json
      result = client.execute(params)
      if result.status != 200
        msg = "Error on import event (Status=#{result.status}): #{result.body}"
        logger.error msg
        raise msg
      end
      count += 1
      self.update_attributes! :latest_synced_item_updated_at => event.updated_at
      logger.info "Event '#{event.summary}' (##{event.id}) has been published to calendar '#{self.name}' (##{self.id}) successfully."
      count >= opts[:max] and break
    end

    self.update_attributes! :sync_finished_at => DateTime.now
    logger.info "Event sync completed for calendar '#{name}' (##{id}): #{count} events has been updated (#{DateTime.now.to_i - self.sync_started_at.to_i} secs)."
  end

  def fetch_events(opts = {})
    opts = {:force => false, :max => 2000}.merge opts
    logger.info "Start event sync for calendar '#{name}' (##{id})"
    count = 0

    self.update_attributes! :sync_started_at => DateTime.now

    client = gapi_client
    service = client.discovered_api('calendar', 'v3')

    listparams = {
      :headers => {'Content-Type' => 'application/json'},
      :api_method => service.events.list,
      :parameters => {
        :calendarId => self.external_id,
        :singleEvents => false,
        :showDeleted => true,
        :orderBy => 'updated',
      }
    }

    self.latest_synced_item_updated_at && !opts[:force] and
      listparams[:parameters][:updatedMin] = (self.latest_synced_item_updated_at - 5.minute).utc.strftime("%Y-%m-%dT%H:%M:%SZ")

    default_tz_min = (Time.now.to_datetime.offset * 60 * 24).to_i

    while true
      logger.debug "Getting event list via Google API: #{listparams.inspect}"
      result = client.execute(listparams)
      if result.status != 200
        msg = "Error on getting event list (Status=#{result.status}): #{result.body}"
        logger.error msg
        #logger.error result.inspect
        raise msg
      end
      logger.debug 'Get event list successfully'

      default_tz_min = TZInfo::Timezone.get(result.data.timeZone).current_period.utc_offset / 60

      result.data["items"] or break
      result.data.items.each do |eitem|
        event = Event.find_by_g_id(eitem.id) || Event.new
        begin
          event.load_attrs :google_v3, eitem, :calendar_id => self.external_id, :default_tz_min => default_tz_min
          logger.info "Event sync: #{event.new_record? ? "create new event" : "update event ##{event.id}"}: #{event.summary}"
          event.save!
          count += 1
          self.update_attributes! :latest_synced_item_updated_at => eitem["updated"]
          opts[:max] <= count and break
        rescue => e
          logger.error "Failed to sync event: #{e.class.name}: #{e.to_s} (#{e.backtrace.first})"
          logger.error "Failed item: #{eitem.inspect}"
          raise e
        end
      end
      !result.next_page_token || opts[:max] <= count and break
      listparams[:parameters][:pageToken] = result.next_page_token
    end

    self.update_attributes! :sync_finished_at => DateTime.now
    logger.info "Event sync completed for calendar '#{name}' (##{id}): #{count} events has been updated (#{DateTime.now.to_i - self.sync_started_at.to_i} secs)."
  end

  private
  def trim_attrs
    self[:name].strip!
    self[:external_id].strip!
    self[:io_type].strip!
  end
end
