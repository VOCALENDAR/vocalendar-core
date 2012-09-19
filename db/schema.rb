# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120918215514) do

  create_table "calendars", :force => true do |t|
    t.string   "name",                          :default => "", :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "external_id",                   :default => "", :null => false
    t.datetime "sync_started_at"
    t.string   "io_type",                       :default => "", :null => false
    t.datetime "latest_synced_item_updated_at"
    t.datetime "sync_finished_at"
    t.string   "tag_names_append_str"
    t.string   "tag_names_remove_str"
  end

  add_index "calendars", ["external_id"], :name => "index_calendars_on_external_id"
  add_index "calendars", ["io_type"], :name => "index_calendars_on_type"

  create_table "calendars_tags", :id => false, :force => true do |t|
    t.integer "calendar_id"
    t.integer "tag_id"
  end

  add_index "calendars_tags", ["calendar_id"], :name => "index_calendars_tags_on_calendar_id"
  add_index "calendars_tags", ["tag_id"], :name => "index_calendars_tags_on_tag_id"

  create_table "events", :force => true do |t|
    t.string   "g_calendar_id"
    t.string   "etag",                                            :null => false
    t.string   "status",                 :default => "confirmed"
    t.text     "g_html_link"
    t.text     "summary"
    t.text     "description"
    t.text     "location"
    t.string   "g_color_id"
    t.string   "g_creator_email"
    t.string   "g_creator_display_name"
    t.date     "start_date",                                      :null => false
    t.datetime "start_datetime",                                  :null => false
    t.date     "end_date",                                        :null => false
    t.datetime "end_datetime",                                    :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "g_id"
    t.string   "recur_string"
    t.string   "recur_freq"
    t.integer  "recur_count",            :default => 0,           :null => false
    t.datetime "recur_until"
    t.integer  "recur_interval",         :default => 1,           :null => false
    t.string   "recur_wday"
    t.string   "ical_uid",               :default => "",          :null => false
    t.text     "primary_uri"
    t.integer  "tz_min",                 :default => 540
    t.string   "country",                :default => "jp"
    t.string   "lang",                   :default => "ja"
    t.boolean  "allday",                 :default => false,       :null => false
  end

  add_index "events", ["end_datetime", "status"], :name => "index_events_on_end_datetime_and_status"
  add_index "events", ["g_calendar_id"], :name => "index_events_on_g_calendar_id"
  add_index "events", ["g_id"], :name => "index_events_on_g_id", :unique => true
  add_index "events", ["start_datetime", "status"], :name => "index_events_on_start_datetime_and_status"
  add_index "events", ["status"], :name => "index_events_on_status"
  add_index "events", ["updated_at", "status"], :name => "index_events_on_updated_at_and_status"

  create_table "events_tags", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "tag_id"
  end

  add_index "events_tags", ["event_id"], :name => "index_events_tags_on_event_id"
  add_index "events_tags", ["tag_id"], :name => "index_events_tags_on_tag_id"

  create_table "settings", :force => true do |t|
    t.string   "var",                      :null => false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", :limit => 30
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], :name => "index_settings_on_thing_type_and_thing_id_and_var", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "uris", :force => true do |t|
    t.text     "event_id"
    t.text     "serviceName"
    t.text     "uri"
    t.text     "kind"
    t.text     "body"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
