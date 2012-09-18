require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "simple save" do
    e = events(:one)
    assert e.save, "Simple save failed: #{e.errors.full_messages.join(', ')}"
  end

  test "mangle tentative status" do
    e = events(:one)
    e.status = "tentative"
    assert_equal "tentative", e.status
    assert e.save
    assert_equal "confirmed", e.status
  end

  test "save must fail without ical_uid" do
    e = events(:one)
    e.ical_uid = ''
    assert !e.save
  end

  test "save must fail with blank summary" do
    e = events(:one)
    e.summary = ''
    assert !e.save
  end

  test "save must fail without etag" do
    e = events(:one)
    e.etag = nil
    assert !e.save
  end

  test "save without ical_uid when cancelled" do
    e = events(:one)
    e.ical_uid = ''
    e.status = 'cancelled'
    assert e.save
  end

  test "set dummy date for cancelled" do
    e = events(:one)
    e.status = "cancelled"
    e.start_date = e.start_datetime = e.end_date = e.end_datetime = nil
    assert e.save
  end

  test "zone format" do
    e = events(:one)
    e.tz_min = 0
    assert_equal "+00:00", e.zone 
    e.tz_min = 30
    assert_equal "+00:30", e.zone
    e.tz_min = 90
    assert_equal "+01:30", e.zone
    e.tz_min = -540
    assert_equal "-09:00", e.zone
  end

  test "zone set" do
    e = events(:one)
    e.zone = "+00:00"
    assert_equal 0, e.tz_min
    e.zone = "-00:30"
    assert_equal -30, e.tz_min
    e.zone = "+01:30"
    assert_equal 90, e.tz_min
    e.zone = "-09:30"
    assert_equal -570, e.tz_min
  end

  test "term string" do
    assert_equal Date.today.strftime("%m-%d"), events(:one).term_str
    assert_equal "2010-03-09 12:09 - 14:09", events(:two_hours).term_str
    assert_equal "2010-03-09 - 2010-03-10", events(:two_days).term_str
  end

  test "load google v3 data" do
    hh = {
      "kind"=>"calendar#event",
      "etag"=>"\"VPgt7A32MKJjP8Bq493zO-MXswA/Q09EbXdxZWRKeEVBQUFBQUFBQUFBQT09\"",
      "id"=>"h@00d8590b768fd9797c5c4f31d6596efba9d4a251",
      "status"=>"confirmed",
      "htmlLink"=>
      "https://www.google.com/calendar/event?eid=aEAwMGQ4NTkwYjc2OGZkOTc5N2M1YzRmMzFkNjU5NmVmYmE5ZDRhMjUxIGphcGFuZXNlQGg",
      "created"=>DateTime.parse("2012-09-17T15:55:08.000Z"),
      "updated"=>DateTime.parse("2012-09-17T15:55:08.000Z"),
      "summary"=>"Children's Day",
      "creator"=>
      {"email"=>"japanese@holiday.calendar.google.com",
        "displayName"=>"Japanese Holidays",
        "self"=>true},
      "organizer"=>
      {"email"=>"japanese@holiday.calendar.google.com",
        "displayName"=>"Japanese Holidays",
        "self"=>true},
      "start"=>{"date"=>Date.parse("2011-05-05")},
      "end"=>{"date"=>Date.parse("2011-05-06")},
      "visibility"=>"public",
      "iCalUID"=>"h@00d8590b768fd9797c5c4f31d6596efba9d4a251@google.com",
      "sequence"=>1}
    ha = hash_to_struct hh
    e = events(:one)
    e.load_exfmt :google_v3, ha, :calendar_id => 'dummy_gcal_id'
    assert_equal ha["htmlLink"], e.g_html_link
    assert_equal ha["status"], e.status
    assert_equal ha["etag"], e.etag
    assert_equal ha["iCalUID"], e.ical_uid
    assert_equal 'dummy_gcal_id', e.g_calendar_id
  end
    
end
