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

ActiveRecord::Schema.define(:version => 20120910204947) do

  create_table "calendars", :force => true do |t|
    t.text     "calendar"
    t.text     "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
  end

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
