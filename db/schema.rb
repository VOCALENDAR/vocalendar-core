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

  create_table "calendars", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id", default: "", null: false
    t.datetime "sync_started_at"
    t.string "io_type", default: "", null: false
    t.datetime "latest_synced_item_updated_at"
    t.datetime "sync_finished_at"
    t.string "tag_names_append_str"
    t.string "tag_names_remove_str"
    t.integer "user_id"
    t.index ["external_id"], name: "index_calendars_on_external_id"
    t.index ["io_type"], name: "index_calendars_on_io_type"
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "calendars_tags", id: false, force: :cascade do |t|
    t.integer "calendar_id"
    t.integer "tag_id"
    t.index ["calendar_id"], name: "index_calendars_tags_on_calendar_id"
    t.index ["tag_id"], name: "index_calendars_tags_on_tag_id"
  end

  create_table "event_tag_relations", force: :cascade do |t|
    t.integer "event_id"
    t.integer "tag_id"
    t.integer "pos", default: 1, null: false
    t.string "target_field", default: "", null: false
    t.index ["event_id", "target_field"], name: "index_event_tag_relations_on_event_id_and_target_field"
    t.index ["tag_id"], name: "index_event_tag_relations_on_tag_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "g_calendar_id"
    t.string "etag", null: false
    t.string "status", default: "confirmed"
    t.text "g_html_link"
    t.text "summary"
    t.text "description"
    t.text "location"
    t.string "g_color_id"
    t.string "g_creator_email"
    t.string "g_creator_display_name"
    t.date "start_date", null: false
    t.datetime "start_datetime", null: false
    t.date "end_date", null: false
    t.datetime "end_datetime", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "g_id"
    t.string "recur_string"
    t.string "ical_uid", default: "", null: false
    t.integer "tz_min", default: 540
    t.string "country", default: "jp"
    t.string "lang", default: "ja"
    t.boolean "allday", default: false, null: false
    t.string "twitter_hash"
    t.string "image"
    t.string "timezone", default: "Asia/Tokyo"
    t.string "g_recurring_event_id"
    t.date "recur_orig_start_date"
    t.datetime "recur_orig_start_datetime"
    t.string "g_eid"
    t.string "type", default: "", null: false
    t.integer "primary_link_id"
    t.index ["end_datetime", "status"], name: "index_events_on_end_datetime_and_status"
    t.index ["g_calendar_id"], name: "index_events_on_g_calendar_id"
    t.index ["g_eid"], name: "index_events_on_g_eid"
    t.index ["g_id"], name: "index_events_on_g_id", unique: true
    t.index ["g_recurring_event_id", "recur_orig_start_datetime"], name: "idx_event_recur_info"
    t.index ["primary_link_id"], name: "index_events_on_primary_link_id"
    t.index ["start_datetime", "status"], name: "index_events_on_start_datetime_and_status"
    t.index ["status"], name: "index_events_on_status"
    t.index ["twitter_hash"], name: "index_events_on_twitter_hash"
    t.index ["type"], name: "index_events_on_type"
    t.index ["updated_at", "status"], name: "index_events_on_updated_at_and_status"
  end

  create_table "events_ex_links", id: false, force: :cascade do |t|
    t.integer "event_id"
    t.integer "ex_link_id"
    t.index ["event_id"], name: "index_events_ex_links_on_event_id"
    t.index ["ex_link_id"], name: "index_events_ex_links_on_ex_link_id"
  end

  create_table "ex_link_accesses", force: :cascade do |t|
    t.integer "ex_link_id", null: false
    t.string "ipaddr"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_ex_link_accesses_on_created_at"
    t.index ["ex_link_id", "created_at"], name: "index_ex_link_accesses_on_ex_link_id_and_created_at"
    t.index ["ipaddr", "created_at"], name: "index_ex_link_accesses_on_ipaddr_and_created_at"
    t.index ["user_agent", "created_at"], name: "index_ex_link_accesses_on_user_agent_and_created_at"
  end

  create_table "ex_links", force: :cascade do |t|
    t.string "type"
    t.string "title", default: "", null: false
    t.text "uri", default: "", null: false
    t.string "remote_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "digest", default: "", null: false
    t.text "endpoint_uri"
    t.boolean "disabled", default: false, null: false
    t.index ["digest"], name: "index_ex_links_on_digest", unique: true
    t.index ["type", "remote_id"], name: "index_ex_links_on_type_and_remote_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_id"
    t.integer "user_id"
    t.index ["event_id", "user_id"], name: "index_favorites_on_event_id_and_user_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "histories", force: :cascade do |t|
    t.string "target", null: false
    t.string "target_type"
    t.integer "target_id"
    t.string "action", null: false
    t.integer "user_id"
    t.text "note"
    t.datetime "created_at", null: false
    t.index ["created_at", "target", "target_id"], name: "index_histories_on_created_at_and_target_and_target_id"
    t.index ["user_id", "created_at"], name: "index_histories_on_user_id_and_created_at"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "primary_link_id"
    t.boolean "hidden", default: false, null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["primary_link_id"], name: "index_tags_on_primary_link_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email"
    t.string "google_account"
    t.string "google_auth_token"
    t.string "google_refresh_token"
    t.datetime "google_token_expires_at"
    t.datetime "google_token_issued_at"
    t.boolean "google_auth_valid", default: false, null: false
    t.string "twitter_uid"
    t.string "twitter_nick"
    t.string "twitter_name"
    t.string "twitter_token"
    t.string "twitter_secret"
    t.boolean "twitter_auth_valid", default: false, null: false
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "twitter_token_issued_at"
    t.string "google_auth_scope"
    t.string "google_uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_account"], name: "index_users_on_google_account", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["twitter_uid"], name: "index_users_on_twitter_uid", unique: true
  end

end
