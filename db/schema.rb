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

ActiveRecord::Schema.define(:version => 20120518062418) do

  create_table "calendars", :force => true do |t|
    t.text     "calendar"
    t.text     "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "events", :force => true do |t|
    t.text     "kind"
    t.text     "calendar_id"
    t.text     "event"
    t.text     "etag"
    t.text     "status"
    t.text     "htmlLink"
    t.text     "summary"
    t.text     "description"
    t.text     "location"
    t.text     "colorId"
    t.text     "creatorEmail"
    t.text     "creatorDisplayName"
    t.date     "startDate"
    t.datetime "startDateTime"
    t.text     "startTimeZone"
    t.date     "endDate"
    t.datetime "endDateTime"
    t.text     "endTimeZone"
    t.datetime "created"
    t.datetime "updated"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
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
