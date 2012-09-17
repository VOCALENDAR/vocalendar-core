# -*- encoding: utf-8 -*-
class Calendar < ActiveRecord::Base
  include VocalendarCore::Utils
  default_scope order('io_type desc, name')

  has_many :events, :foreign_key => 'g_calendar_id', :primary_key => 'external_id'

  attr_accessible :name, :external_id, :io_type, :sync_started_at, :sync_finished_at, :latest_synced_item_updated_at

  validates :name, :presence => true
  validates :external_id, :presence => true, :uniqueness => true
  validates :io_type, :presence => true, :inclusion => {:in => %w(src dst)}

  before_validation :trim_attrs

  def sync_events(opts = {})
    io_type == 'dst' and publish_events(opts)
    io_type == 'src' and feed_events(opts)
  end

  def publish_events(opts = {})
    raise NotImplementedError, "TODO"
  end

  def feed_events(opts = {})
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

        summary = eitem["summary"].to_s.strip
        tag_names = []
        while summary.sub!(/^【(.*?)】/, '')
          tag_names += $1.split(%r{[/／]}).map {|t| t.strip }
        end
        event.tag_names = tag_names

        begin
          event.attributes = {
            g_id: eitem.id,
            etag: eitem.etag,
            status: eitem.status,
            summary: summary.strip,
            description: eitem["description"],
            location: eitem["location"],
            g_html_link: eitem["htmlLink"],
            g_calendar_id: self.external_id,
            g_creator_email: eitem["creator"].try(:email),
            ical_uid: eitem["iCalUID"].to_s,
          }
          if eitem["start"] 
            event.attributes = {
              start_datetime: eitem.start["dateTime"] || eitem.start.date.to_time.to_datetime,
              start_date: eitem.start["date"] || eitem.start.dateTime.to_date,
              end_datetime: eitem.end["dateTime"] || eitem.end.date.to_time.to_datetime,
              end_date: eitem.end["date"] || eitem.end.dateTime.to_date,
              tz_min: eitem.start["date"] ? default_tz_min : (eitem.start.dateTime.to_datetime.offset * 60 * 24).to_i,
              allday: !!eitem.start["date"],
              # TODO: recurrent support MUST!!!
              # TODO: support color_id support or drop 
              # TODO: support g_creator_display_name or drop
            }
          end
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
