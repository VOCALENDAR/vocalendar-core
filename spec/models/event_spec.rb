require 'spec_helper'

describe Event do
  let(:valid_attrs) do 
    {
      :summary => "Summary text at #{DateTime.now}",
      :start_datetime => DateTime.now,
      :end_datetime => DateTime.now,
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
    e.save!
    e.main_tag_relations.map {|r| r.pos }.should eql (1..5).to_a
    e.tag_names = %w(m n o p)
    e.save!
    e.main_tag_relations.map {|r| r.pos }.should eql (1..4).to_a
  end

  it "keeps tag order" do
    e = Event.new(valid_attrs)
    e.tag_names_str = "x y a b 0"
    e.save!
    Event.find(e.id).tag_names.should eql %w(x y a b 0)
    e.tag_names = %w(Z ii hhh 0000)
    e.save!
    Event.find(e.id).tag_names.should eql %w(Z ii hhh 0000)
  end

  it "mangles tentative status when save" do
    e = an_event
    e.status = "tentative"
    e.status.should == "tentative"
    assert e.save
    e.status.should == "confirmed"
  end

  it "save sucesss without ical_uid if cancelled" do
    e = an_event
    e.ical_uid = ''
    e.status = 'cancelled'
    e.save.should be_true
  end

  it "raises exception on tz_min=" do
    lambda { an_event.tz_min = 30 }.should raise_error(ArgumentError, /timezone=/)
  end

  it "returns time zone object" do
    e = an_event
    e.timezone.should be_instance_of(ActiveSupport::TimeZone)
    e.timezone = 'UTC'
    e.timezone.should be_instance_of(ActiveSupport::TimeZone)
  end

  it ": set time zone" do
    e = an_event
    e.timezone = 'UTC'
    e.timezone.name.should eq 'UTC'
    e.timezone.utc_offset.should eq 0
    e.timezone = 'Asia/Tokyo'
    e.timezone.name.should eq 'Asia/Tokyo'
    e.timezone.utc_offset.should eq 32400
    e.timezone.formatted_offset.should eq '+09:00'
  end

  it "dose NOT change by start_datetime" do
    e = an_event
    e.timezone = 'UTC'
    e.start_datetime = '2012-03-09T03:09:00+09:00'
    e.tz_min.should eq 0
    e.timezone.utc_offset.should eq 0
  end

  it "changes tz_min by setting time zone" do
    e = an_event
    e.timezone = 'UTC'
    e.tz_min.should eq 0
    e.timezone = 'Asia/Tokyo'
    e.tz_min.should eq 540
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
    e.end_datetime   = Time.new(2010, 3, 11, 15, 9)
    e.term_str.should == "2010-03-09 15:09 - 2010-03-11 15:09"

    e = an_event
    e.allday = true
    e.start_datetime = Time.new(2010, 3, 11, 0, 0)
    e.end_datetime   = Time.new(2010, 3, 12, 0, 0)
    e.term_str.should == "2010-03-11"
  end

  it "endtime must be treated as open interval: [start, end)" do
    e = an_event
    e.allday = true

    e.start_date     = Date.new(2010, 3, 9)
    e.end_date       = Date.new(2010, 3, 10)
    e.term_str.should == "2010-03-09"

    e.start_datetime = Date.new(2010, 3, 9)
    e.end_datetime   = Date.new(2010, 3, 10)
    e.term_str.should == "2010-03-09"

    e.start_datetime = Date.new(2010, 3, 9)
    e.end_datetime   = Date.new(2010, 3, 11)
    e.term_str.should == "2010-03-09 - 2010-03-10"

    e.start_date     = Date.new(2010, 3, 9)
    e.end_date       = Date.new(2010, 3, 11)
    e.term_str.should == "2010-03-09 - 2010-03-10"

    e.start_datetime = Time.new(2010, 3, 9, 15, 9)
    e.end_datetime   = Time.new(2010, 3, 10, 15, 9)
    e.term_str.should == "2010-03-09 - 2010-03-10"

    e.start_date     = Time.new(2010, 3, 9, 15, 9)
    e.end_date       = Time.new(2010, 3, 10, 15, 9)
    e.term_str.should == "2010-03-09"

    e.end_datetime   = Time.new(2010, 3, 12, 15, 9)
    e.term_str.should == "2010-03-09 - 2010-03-12"

    e.end_datetime   = Date.new(2010, 3, 12)
    e.term_str.should == "2010-03-09 - 2010-03-11"
  end

  it "can be changed time only by set {start,end}_time " do
    e = an_event
    keepdate = e.start_date
    e.start_time = "12:30"
    e.start_date.should eq keepdate

    e.start_date = "2012-03-09"
    e.start_time.should eq "00:00"
    e.start_time = "03:09"
    e.start_datetime.should eq Time.new(2012, 3, 9, 3, 9, 0).to_datetime
  end


  it ": Load and convert Google Calendar API v3 JSON format" do
    google_input = {
      "kind"=>"calendar#event",
      "etag"=>"\"VPgt7A32MKJjP8Bq493zO-MXswA/Q09EbXdxZWRKeEVBQUFBQUFBQUFBQT09\"",
      "id"=>"h@00d8590b768fd9797c5c4f31d6596efba9d4a251",
      "status"=>"confirmed",
      "htmlLink"=>
      "https://www.google.com/calendar/event?eid=aEAwMGQ4NTkwYjc2OGZkOTc5N2M1YzRmMzFkNjU5NmVmYmE5ZDRhMjUxIGphcGFuZXNlQGg",
      "created"=>DateTime.parse("2012-09-17T15:55:08.000Z"),
      "updated"=>DateTime.parse("2012-09-17T15:55:08.000Z"),
      "summary"=>"Children's Day",
      "creator"=> {
        "email"=>"japanese@holiday.calendar.google.com",
	"displayName"=>"Japanese Holidays",
	"self"=>true
      },
      "organizer"=> {
        "email"=>"japanese@holiday.calendar.google.com",
	"displayName"=>"Japanese Holidays",
	"self"=>true
      },
      "start"=>{"date"=>Date.parse("2011-05-05")},
      "end"=>{"date"=>Date.parse("2011-05-06")},
      "visibility"=>"public",
      "iCalUID"=>"h@00d8590b768fd9797c5c4f31d6596efba9d4a251@google.com",
      "sequence"=>1,
      "recurrence"=>["RRULE:FREQ=YEARLY;WKST=SU"],
    }
    google_input = Hashie::Mash.new(google_input)
    e = an_event
    e.load_exfmt :google_v3, google_input, :calendar_id => 'dummy_gcal_id'
    e.g_html_link.should   == google_input["htmlLink"]
    e.status.should        == google_input["status"]
    e.etag.should          == google_input["etag"]
    e.ical_uid.should      == google_input["iCalUID"]
    e.g_calendar_id.should == 'dummy_gcal_id'

    output = e.to_exfmt :google_v3
    pending "Not yet decided to add 'id' for google sync" do
      output[:id].should == google_input[:id]
    end
    %w(summary status start end recurrence iCalUID recurringEventId).each do |f|
      output[f].should == google_input[f]
    end
  end

  it "keeps info while Google JSON convertion" do
    google_input =  {
      kind: "calendar#event",
      etag: "\"NybCyMgjkLQM6Il-p8A5652MtaE/Q09EdnpMU3pKeEVBQUFBQUFBQUFBQT09\"",
      id: "5i7288vqns7o91d95l52t4dbss_20121128T010000Z",
      status: "confirmed",
      htmlLink: "https://www.google.com/calendar/event?eid=NWk3Mjg4dnFuczdvOTFkOTVsNTJ0NGRic3NfMjAxMjExMjhUMDEwMDAwWiB0YXRzdWtpLnN1Z2l1cmFAbQ",
      created: "2012-11-25T07:32:19.000Z",
      updated: "2012-11-25T07:58:36.000Z",
      summary: "test2",
      creator: {
        email: "tatsuki.sugiura@gmail.com",
        displayName: "Tatsuki SUGIURA",
        self: true
      },
      organizer: {
        email: "tatsuki.sugiura@gmail.com",
        displayName: "Tatsuki SUGIURA",
        self: true
      },
      start: {
        dateTime: DateTime.parse("2012-11-27T12:30:00+09:00"),
        timeZone: "Asia/Taipei"
      },
      "end" => {
        dateTime: DateTime.parse("2012-11-27T13:30:00+09:00"),
        timeZone: "Asia/Taipei"
      },
      recurringEventId: "5i7288vqns7o91d95l52t4dbss",
      originalStartTime: {
        dateTime: DateTime.parse("2012-11-28T10:00:00+09:00"),
        timeZone: "Asia/Taipei",
      },
      transparency: "transparent",
      iCalUID: "5i7288vqns7o91d95l52t4dbss@google.com",
      sequence: 3,
      reminders: {
        useDefault: true
      }
    }
    google_input = Hashie::Mash.new(google_input)
    e = an_event
    e.load_exfmt :google_v3, google_input.dup, :calendar_id => 'dummy_gcal_id'
    output = e.to_exfmt :google_v3

    %w(id summary status start end iCalUID recurringEventId).each do |f|
      next if f == 'id' # "Not yet decided to add 'id' for google sync"
      output[f].should == google_input[f]
    end

    output[:start][:dateTime].should == google_input[:start][:dateTime]
    output[:start][:timeZone].should == google_input[:start][:timeZone]
    output[:end][:dateTime].should == google_input[:end][:dateTime]
    output[:end][:timeZone].should == google_input[:end][:timeZone]
    output[:originalStartTime][:dateTime].should == google_input[:originalStartTime][:dateTime]
    output[:originalStartTime][:timeZone].should == google_input[:originalStartTime][:timeZone]

    google_input[:start] = Hashie::Mash.new({:date => Date.parse("2012-03-09")})
    google_input[:end]   = Hashie::Mash.new({:date => Date.parse("2012-03-10")})
    google_input[:originalStartTime] = Hashie::Mash.new({:date => Date.parse("2012-03-03")})
    e = an_event
    e.load_exfmt :google_v3, google_input, :calendar_id => 'dummy_gcal_id'
    output = e.to_exfmt :google_v3
    output[:originalStartTime].should == google_input[:originalStartTime]
    output[:originalStartTime][:date].should == google_input[:originalStartTime][:date]
  end

  it "saves extra tags" do
    e = an_event
    e.tag_names = %w(should keep ordinal tags)
    e.extra_tags[:hoge].should eq []
    e.extra_tags[:hoge].should be_a(Event::ExtraTagContainer::TagContainer)
    e.extra_tags[:ext1].names_str = "hoge fuga/funya"
    e.extra_tags[:ext1].names.should eq %w(hoge fuga funya)
    e.extra_tags[:ext2].names_str = "a"
    e.extra_tags[:ext2].names.should eq %w(a)
    e.extra_tags[:ext1].names.should eq %w(hoge fuga funya)
    e.save!
    en = Event.find(e.id)
    en.extra_tags[:ext1].names.should eq %w(hoge fuga funya)
    en.tag_names.should eq %w(should keep ordinal tags)

    e.extra_tags[:ext1].names = %w(z 1)
    e.extra_tags[:ext1].names.should eq %w(z 1)
    e.extra_tags[:ext2].names = %w(z 2 1)
    e.extra_tags[:ext2].names.should eq %w(z 2 1)
    e.save!

    en = Event.find(e.id)
    en.extra_tags[:ext1].names.should eq %w(z 1)
    en.extra_tags[:ext2].names.should eq %w(z 2 1)
    en.extra_tag_relations.should have(5).items
    en.tag_names.should eq %w(should keep ordinal tags)

  end

  it "should accept single string as extra tag name" do
    e = an_event
    e.extra_tags[:hoge].names = "simple tag name"
    e.extra_tags[:hoge].names.should eq ["simple_tag_name"]
  end

  it "replaces space in tag name" do
    e = an_event
    e.tag_names = ["Hellow, World", "Good      Bye"]
    e.tag_names.should eq ["Hellow,_World", "Good_Bye"]
    e.tags[0].name.should eq "Hellow,_World"
    e.tags[1].name.should eq "Good_Bye"
  end

  it "respond recurring_instance?" do
    e = an_event
    e.recurring_instance?.should be_false
    e.g_recurring_event_id = "abcdef"
    e.recurring_instance?.should be_true
    e.g_recurring_event_id = nil
    e.recurring_instance?.should be_false
    e.g_recurring_event_id = ""
    e.recurring_instance?.should be_false
  end

  it "generates etag automatically" do
    e = an_event
    e.etag.should be_blank
    e.save!
    e.etag.should_not be_blank
  end

  it "changes etag when attribute updates" do
    e = an_event
    e.save!
    prev_etag = e.etag
    e.summary = "test"
    e.etag.should eq prev_etag
    e.save!
    e.etag.should_not eq prev_etag
    e.etag.should_not be_blank
  end

  it "acceept conditional tag name query" do
    e = an_event
    e.tag_names = %w(Tag query test)
    e.save!
    e.tag_names(:name => "Tag").should eq %w(Tag)

    t1 = Tag.create(:name => "time-#{Time.now.to_i}")
    sleep 1
    t2 = Tag.create(:name => "time-#{Time.now.to_i}")
    e.tag_ids = [t1, t2].map{|t| t.id}
    e.save!

    e.tag_names(:created_at => t1.created_at).should eq [t1.name]
  end
    
  it "hides hidden tags when convert to google v3 JSON" do
    e = an_event
    e.tag_names = %w(This is hidden tag test)
    e.save!

    Tag.find_by_name!("hidden").update_attribute :hidden, true
    e.tag_names(:hidden => false).should eq %w(This is tag test)

    Tag.find_by_name!("test"  ).update_attribute :hidden, true
    e.tag_names(:hidden => false).should eq %w(This is tag)
  end
end
