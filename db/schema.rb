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

ActiveRecord::Schema.define(:version => 20121116181038) do

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
    t.integer  "user_id"
  end

  add_index "calendars", ["external_id"], :name => "index_calendars_on_external_id"
  add_index "calendars", ["io_type"], :name => "index_calendars_on_type"
  add_index "calendars", ["user_id"], :name => "index_calendars_on_user_id"

  create_table "calendars_tags", :id => false, :force => true do |t|
    t.integer "calendar_id"
    t.integer "tag_id"
  end

  add_index "calendars_tags", ["calendar_id"], :name => "index_calendars_tags_on_calendar_id"
  add_index "calendars_tags", ["tag_id"], :name => "index_calendars_tags_on_tag_id"

  create_table "event_tag_relations", :force => true do |t|
    t.integer "event_id"
    t.integer "tag_id"
    t.integer "pos",          :default => 1, :null => false
    t.string  "target_field"
  end

  add_index "event_tag_relations", ["event_id"], :name => "index_event_tag_relations_on_event_id"
  add_index "event_tag_relations", ["tag_id"], :name => "index_event_tag_relations_on_tag_id"

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
    t.text     "uri"
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

  create_table "users", :force => true do |t|
    t.string   "name",                    :default => "",    :null => false
    t.string   "email"
    t.string   "google_account"
    t.string   "google_auth_token"
    t.string   "google_refresh_token"
    t.string   "google_token_expires_at"
    t.string   "google_token_issued_at"
    t.boolean  "google_auth_valid",       :default => false, :null => false
    t.string   "twitter_uid"
    t.string   "twitter_nick"
    t.string   "twitter_name"
    t.string   "twitter_token"
    t.string   "twitter_secret"
    t.boolean  "twitter_auth_valid",      :default => false, :null => false
    t.integer  "sign_in_count",           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "role"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["google_account"], :name => "index_users_on_google_account", :unique => true
  add_index "users", ["role"], :name => "index_users_on_role"
  add_index "users", ["twitter_uid"], :name => "index_users_on_twitter_uid", :unique => true

end
