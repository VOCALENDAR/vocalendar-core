class Event < ActiveRecord::Base
  attr_accessible :g_calendar_id, :description, :etag, :g_html_ink,
    :location, :status, :summary, :g_color_id, :g_creator_email,
    :g_creator_display_name, :start_date, :start_datetime, 
    :end_date, :end_datetime, :g_id, :recur_string, :recur_freq,
    :recur_count, :recur_until, :recur_interval, :recur_wday,
    :ical_uid, :tz_min, :country, :lang
  has_many :uris
end
