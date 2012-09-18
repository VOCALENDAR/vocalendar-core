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
end
