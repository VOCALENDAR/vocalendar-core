require 'spec_helper'

def hash_to_struct(h)
  h.each do |k, v|
    Hash === v or next
    h[k] = hash_to_struct(v)
  end
  s = OpenStruct.new(h)
  def s.[](k)
    self.__send__ k
  end
  s
end


describe Event do
  let(:valid_attrs) do 
    {
      :etag => 'etag-string',
      :summary => "Summary text at #{DateTime.now}",
      :start_datetime => DateTime.now,
      :end_datetime => DateTime.now,
      :ical_uid => 'ical-uid-string',
    }
  end

  let(:an_event) do
    Event.new valid_attrs
  end

  it "save will success with valid attributs" do
    Event.new(valid_attrs).save.should be_true
  end

  it "save will fail without summary text" do
    attrs = valid_attrs
    attrs.delete :summary
    Event.new(attrs).save.should be_false
  end

  it "save with tag str" do
    e = an_event
    e.tag_names_str = "aa/bb cc   dd//ee"
    e.tag_names.should eql %w(aa bb cc dd ee)
    e.save.should be_true
    Event.find(e.id).tag_names.should eql %w(aa bb cc dd ee)
  end

  it "saves tag relation postion" do
    e = an_event
    e.tag_names_str = "a b c d e"
    e.save
    e.tag_relations.map {|r| r.pos }.should eql (1..5).to_a
    e.tag_names = %w(m n o p)
    e.save
    e.tag_relations.map {|r| r.pos }.should eql (1..4).to_a
  end

  it "keeps tag order" do
    e = Event.new(valid_attrs)
    e.tag_names_str = "x y a b 0"
    e.save
    Event.find(e.id).tag_names.should eql %w(x y a b 0)
    e.tag_names = %w(Z ii hhh 0000)
    e.save
    Event.find(e.id).tag_names.should eql %w(Z ii hhh 0000)
  end

  it "mangles tentative status when save" do
    e = an_event
    e.status = "tentative"
    e.status.should == "tentative"
    assert e.save
    e.status.should == "confirmed"
  end

  it "save must be failed without ical_uid" do
    e = an_event
    e.ical_uid = ''
    e.save.should be_false
  end

  it "save must be failed without etag" do
    e = an_event
    e.etag = nil
    e.save.should be_false
  end

  it "save sucesss without ical_uid if cancelled" do
    e = an_event
    e.ical_uid = ''
    e.status = 'cancelled'
    e.save.should be_true
  end

  it ": Time zone format in string" do
    e = an_event
    e.tz_min = 0
    e.zone.should == "+00:00"
    e.tz_min = 30
    e.zone.should == "+00:30"
    e.tz_min = -30
    e.zone.should == "-00:30"
    e.tz_min = 90
    e.zone.should == "+01:30"
    e.tz_min = -90
    e.zone.should == "-01:30"
    e.tz_min = 540
    e.zone.should == "+09:00"
    e.tz_min = -540
    e.zone.should == "-09:00"
  end

  it ": Set timezone by string" do
    e = an_event
    e.zone = "+00:00"
    e.tz_min.should == 0
    e.zone = "-00:30"
    e.tz_min.should == -30
    e.zone = "+01:30"
    e.tz_min.should == 90
    e.zone = "-09:30"
    e.tz_min.should == -570
  end

  it ": Set offset" do
    e = an_event
    e.offset = Rational(9, 24)
    e.tz_min.should == 540
    e.zone.should == "+09:00"
    e.offset = Rational(-0.5, 24)
    e.tz_min.should == -30
    e.zone.should == "-00:30"
  end

  it ": Term string formatting" do
    e = an_event
    now = DateTime.now
    e.start_datetime = now
    e.end_datetime   = now
    e.allday = false
    e.term_str.should == now.strftime("%m-%d %H:%M")

    e.allday = true
    e.term_str.should == now.strftime("%m-%d")

    e.allday = false
    e.start_datetime = Time.new(2010, 3, 9, 15, 9)
    e.end_datetime   = Time.new(2010, 3, 9, 17, 9)
    e.term_str.should == "2010-03-09 15:09 - 17:09"

    e.allday = true
    e.term_str.should == "2010-03-09"

    e.allday = false
    e.end_datetime   = Time.new(2010, 3, 10, 15, 9)
    e.term_str.should == "2010-03-09 15:09 - 2010-03-10 15:09"

    e.allday = true
    e.term_str.should == "2010-03-09 - 2010-03-10"
  end

  it ": Load Google Calendar API v3 JSON format" do
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
	"sequence"=>1
    }
    ha = hash_to_struct hh
    e = an_event
    e.load_exfmt :google_v3, ha, :calendar_id => 'dummy_gcal_id'
    e.g_html_link.should   == ha["htmlLink"]
    e.status.should        == ha["status"]
    e.etag.should          == ha["etag"]
    e.ical_uid.should      == ha["iCalUID"]
    e.g_calendar_id.should == 'dummy_gcal_id'
  end

end
