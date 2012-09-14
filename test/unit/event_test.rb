require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "simple save" do
    assert events(:one).save
  end

  test "simple save2" do
    assert events(:one).save
  end

  test "mangle tentative status" do
    e = events(:one)
    e.status = "tentative"
    assert e.save
    assert_equal e.status, "confirmed"
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
end
