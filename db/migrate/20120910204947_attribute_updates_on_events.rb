class AttributeUpdatesOnEvents < ActiveRecord::Migration
  def up
    # Use underscore with ruby-izm and add "g_" prefix for google specific attributes
    rename_column :events, :htmlLink, :g_html_link
    rename_column :events, :colorId, :g_color_id
    rename_column :events, :creatorEmail, :g_creator_email
    rename_column :events, :creatorDisplayName, :g_creator_display_name
    rename_column :events, :startDate, :start_date
    rename_column :events, :startDateTime, :start_datetime
    rename_column :events, :endDate, :end_date
    rename_column :events, :endDateTime, :end_datetime
    rename_column :events, :calendar_id, :g_calendar_id

    # Set default and constraint
    change_column :events, :start_date, :date, :null => false
    change_column :events, :end_date, :date, :null => false
    change_column :events, :start_datetime, :datetime, :null => false
    change_column :events, :end_datetime, :datetime, :null => false
    change_column :events, :status, :string, :default => 'confirmed'
    change_column :events, :etag, :string, :null => false
    change_column :events, :g_creator_email, :string
    change_column :events, :g_creator_display_name, :string
    change_column :events, :g_color_id, :string
    change_column :events, :g_calendar_id, :string
    
    # remove
    remove_column :events, :endTimeZone
    remove_column :events, :startTimeZone
    remove_column :events, :created
    remove_column :events, :updated
    remove_column :events, :kind
    remove_column :events, :event
    
    # add cols
    add_column :events, :g_id, :string
    add_column :events, :recur_string, :string
    add_column :events, :recur_freq, :string
    add_column :events, :recur_count, :integer, :null => false, :default => 0
    add_column :events, :recur_until, :datetime
    add_column :events, :recur_interval, :integer, :null => false, :default => 1
    add_column :events, :recur_wday, :string
    add_column :events, :ical_uid, :string, :null => false, :default => ''
    add_column :events, :primary_uri, :text
    add_column :events, :tz_min, :integer, :default => 540
    add_column :events, :country, :string, :default => 'jp'
    add_column :events, :lang, :string, :default => 'ja'
  end

  def down
    raise "Cant' revert this migration."
  end
end
