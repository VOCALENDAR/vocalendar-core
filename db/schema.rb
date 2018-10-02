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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140501155619) do

  create_table "calendars", force: true do |t|
    t.string   "name",                          default: "", null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "external_id",                   default: "", null: false
    t.datetime "sync_started_at"
    t.string   "io_type",                       default: "", null: false
    t.datetime "latest_synced_item_updated_at"
    t.datetime "sync_finished_at"
    t.string   "tag_names_append_str"
    t.string   "tag_names_remove_str"
    t.integer  "user_id"
  end

  add_index "calendars", ["external_id"], name: "index_calendars_on_external_id", using: :btree
  add_index "calendars", ["io_type"], name: "index_calendars_on_type", using: :btree
  add_index "calendars", ["user_id"], name: "index_calendars_on_user_id", using: :btree

  create_table "calendars_tags", id: false, force: true do |t|
    t.integer "calendar_id"
    t.integer "tag_id"
  end

  add_index "calendars_tags", ["calendar_id"], name: "index_calendars_tags_on_calendar_id", using: :btree
  add_index "calendars_tags", ["tag_id"], name: "index_calendars_tags_on_tag_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name",                                  null: false
    t.integer  "order_class",           default: 200,   null: false
    t.text     "description"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "disabled",              default: false
    t.integer  "sub_category_group_id"
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree
  add_index "categories", ["order_class", "name"], name: "index_categories_on_order_class_and_name", using: :btree

  create_table "event_tag_relations", force: true do |t|
    t.integer "event_id"
    t.integer "tag_id"
    t.integer "pos",          default: 1,  null: false
    t.string  "target_field", default: "", null: false
  end

  add_index "event_tag_relations", ["event_id", "target_field"], name: "index_event_tag_relations_on_event_id_and_target_field", using: :btree
  add_index "event_tag_relations", ["tag_id"], name: "index_event_tag_relations_on_tag_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "g_calendar_id"
    t.string   "etag",                                             null: false
    t.string   "status",                    default: "confirmed"
    t.text     "g_html_link"
    t.text     "summary"
    t.text     "description"
    t.text     "location"
    t.string   "g_color_id"
    t.string   "g_creator_email"
    t.string   "g_creator_display_name"
    t.date     "start_date",                                       null: false
    t.datetime "start_datetime",                                   null: false
    t.date     "end_date",                                         null: false
    t.datetime "end_datetime",                                     null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "g_id"
    t.string   "recur_string"
    t.string   "ical_uid",                  default: "",           null: false
    t.integer  "tz_min",                    default: 540
    t.string   "country",                   default: "jp"
    t.string   "lang",                      default: "ja"
    t.boolean  "allday",                    default: false,        null: false
    t.string   "twitter_hash"
    t.string   "image"
    t.string   "timezone",                  default: "Asia/Tokyo"
    t.string   "g_recurring_event_id"
    t.date     "recur_orig_start_date"
    t.datetime "recur_orig_start_datetime"
    t.string   "g_eid"
    t.string   "type",                      default: "",           null: false
    t.integer  "primary_link_id"
  end

  add_index "events", ["end_datetime", "status"], name: "index_events_on_end_datetime_and_status", using: :btree
  add_index "events", ["g_calendar_id"], name: "index_events_on_g_calendar_id", using: :btree
  add_index "events", ["g_eid"], name: "index_events_on_g_eid", using: :btree
  add_index "events", ["g_id"], name: "index_events_on_g_id", unique: true, using: :btree
  add_index "events", ["g_recurring_event_id", "recur_orig_start_datetime"], name: "idx_event_recur_info", using: :btree
  add_index "events", ["primary_link_id"], name: "index_events_on_primary_link_id", using: :btree
  add_index "events", ["start_datetime", "status"], name: "index_events_on_start_datetime_and_status", using: :btree
  add_index "events", ["status"], name: "index_events_on_status", using: :btree
  add_index "events", ["twitter_hash"], name: "index_events_on_twitter_hash", using: :btree
  add_index "events", ["type"], name: "index_events_on_type", using: :btree
  add_index "events", ["updated_at", "status"], name: "index_events_on_updated_at_and_status", using: :btree

  create_table "events_ex_links", id: false, force: true do |t|
    t.integer "event_id"
    t.integer "ex_link_id"
  end

  add_index "events_ex_links", ["event_id"], name: "index_events_ex_links_on_event_id", using: :btree
  add_index "events_ex_links", ["ex_link_id"], name: "index_events_ex_links_on_ex_link_id", using: :btree

  create_table "ex_link_accesses", force: true do |t|
    t.integer  "ex_link_id", null: false
    t.string   "ipaddr"
    t.string   "user_agent"
    t.datetime "created_at", null: false
  end

  add_index "ex_link_accesses", ["created_at"], name: "index_ex_link_accesses_on_created_at", using: :btree
  add_index "ex_link_accesses", ["ex_link_id", "created_at"], name: "index_ex_link_accesses_on_ex_link_id_and_created_at", using: :btree
  add_index "ex_link_accesses", ["ipaddr", "created_at"], name: "index_ex_link_accesses_on_ipaddr_and_created_at", using: :btree
  add_index "ex_link_accesses", ["user_agent", "created_at"], name: "index_ex_link_accesses_on_user_agent_and_created_at", using: :btree

  create_table "ex_links", force: true do |t|
    t.string   "type"
    t.string   "title",        default: "",    null: false
    t.text     "uri",                          null: false
    t.string   "remote_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "digest",       default: "",    null: false
    t.text     "endpoint_uri"
    t.boolean  "disabled",     default: false, null: false
  end

  add_index "ex_links", ["digest"], name: "index_ex_links_on_digest", unique: true, using: :btree
  add_index "ex_links", ["type", "remote_id"], name: "index_ex_links_on_type_and_remote_id", using: :btree

  create_table "favorites", force: true do |t|
    t.integer  "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "event_id"
    t.integer  "user_id"
  end

  add_index "favorites", ["event_id", "user_id"], name: "index_favorites_on_event_id_and_user_id", using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

  create_table "histories", force: true do |t|
    t.string   "target",      null: false
    t.string   "target_type"
    t.integer  "target_id"
    t.string   "action",      null: false
    t.integer  "user_id"
    t.text     "note"
    t.datetime "created_at",  null: false
  end

  add_index "histories", ["created_at", "target", "target_id"], name: "index_histories_on_created_at_and_target_and_target_id", using: :btree
  add_index "histories", ["user_id", "created_at"], name: "index_histories_on_user_id_and_created_at", using: :btree

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: true do |t|
    t.string   "name",         null: false
    t.string   "uid",          null: false
    t.string   "secret",       null: false
    t.text     "redirect_uri", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "sub_categories", force: true do |t|
    t.string   "name",                        null: false
    t.text     "description"
    t.integer  "group_id",    default: 1,     null: false
    t.integer  "order_class", default: 200,   null: false
    t.boolean  "disabled",    default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "sub_categories", ["group_id"], name: "index_sub_categories_on_group_id", using: :btree

  create_table "submissions", force: true do |t|
    t.string   "title",           default: "",    null: false
    t.datetime "start_datetime",                  null: false
    t.datetime "end_datetime",                    null: false
    t.boolean  "all_day",         default: false, null: false
    t.text     "where"
    t.text     "description"
    t.integer  "status_id",       default: 1,     null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "accepted_at"
    t.integer  "category_id"
    t.text     "url"
    t.integer  "sub_category_id"
  end

  add_index "submissions", ["accepted_at", "status_id"], name: "index_submissions_on_accepted_at_and_status_id", using: :btree
  add_index "submissions", ["created_at"], name: "index_submissions_on_created_at", using: :btree
  add_index "submissions", ["start_datetime"], name: "index_submissions_on_start_datetime", using: :btree
  add_index "submissions", ["status_id"], name: "index_submissions_on_status_id", using: :btree
  add_index "submissions", ["updated_at"], name: "index_submissions_on_updated_at", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name",            default: "",    null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "primary_link_id"
    t.boolean  "hidden",          default: false, null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["primary_link_id"], name: "index_tags_on_primary_link_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                    default: "",    null: false
    t.string   "email"
    t.string   "google_account"
    t.string   "google_auth_token"
    t.string   "google_refresh_token"
    t.datetime "google_token_expires_at"
    t.datetime "google_token_issued_at"
    t.boolean  "google_auth_valid",       default: false, null: false
    t.string   "twitter_uid"
    t.string   "twitter_nick"
    t.string   "twitter_name"
    t.string   "twitter_token"
    t.string   "twitter_secret"
    t.boolean  "twitter_auth_valid",      default: false, null: false
    t.integer  "sign_in_count",           default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "role"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.datetime "twitter_token_issued_at"
    t.string   "google_auth_scope"
    t.string   "google_uid"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["google_account"], name: "index_users_on_google_account", unique: true, using: :btree
  add_index "users", ["role"], name: "index_users_on_role", using: :btree
  add_index "users", ["twitter_uid"], name: "index_users_on_twitter_uid", unique: true, using: :btree

end
