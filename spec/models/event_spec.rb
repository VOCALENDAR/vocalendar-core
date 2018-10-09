require 'rails_helper'

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
    expect(Event.new(valid_attrs).save).to be true
  end

  it "save will fail without summary text" do
    attrs = valid_attrs
    attrs.delete :summary
    expect(Event.new(attrs).save).to be false
  end

  it "save with tag str" do
    e = an_event
    e.tag_names_str = "aa/bb cc   dd//ee"
    expect(e.tag_names).to eql %w(aa bb cc dd ee)
    expect(e.save).to be_truthy
    expect(Event.find(e.id).tag_names).to eql %w(aa bb cc dd ee)
  end

  it "saves tag relation postion" do
    e = an_event
    e.tag_names_str = "a b c d e"
    e.save!
    expect(e.main_tag_relations.map {|r| r.pos }).to eql (1..5).to_a
    e.tag_names = %w(m n o p)
    e.save!
    expect(e.main_tag_relations.map {|r| r.pos }).to eql (1..4).to_a
  end

  it "keeps tag order" do
    e = Event.new(valid_attrs)
    e.tag_names_str = "x y a b 0"
    e.save!
    expect(Event.find(e.id).tag_names).to eql %w(x y a b 0)
    e.tag_names = %w(Z ii hhh 0000)
    e.save!
    expect(Event.find(e.id).tag_names).to eql %w(Z ii hhh 0000)
  end

  it "mangles tentative status when save" do
    e = an_event
    e.status = "tentative"
    expect(e.status).to eq("tentative")
    assert e.save
    expect(e.status).to eq("confirmed")
  end

  it "save sucesss without ical_uid if cancelled" do
    e = an_event
    e.ical_uid = ''
    e.status = 'cancelled'
    expect(e.save).to be true
  end

  it "raises exception on tz_min=" do
    expect { an_event.tz_min = 30 }.to raise_error(ArgumentError, /timezone=/)
  end

  it "returns time zone object" do
    e = an_event
    expect(e.timezone).to be_instance_of(ActiveSupport::TimeZone)
    e.timezone = 'UTC'
    expect(e.timezone).to be_instance_of(ActiveSupport::TimeZone)
  end

  it ": set time zone" do
    e = an_event
    e.timezone = 'UTC'
    expect(e.timezone.name).to eq 'UTC'
    expect(e.timezone.utc_offset).to eq 0
    e.timezone = 'Asia/Tokyo'
    expect(e.timezone.name).to eq 'Asia/Tokyo'
    expect(e.timezone.utc_offset).to eq 32400
    expect(e.timezone.formatted_offset).to eq '+09:00'
  end

  it "dose NOT change by start_datetime" do
    e = an_event
    e.timezone = 'UTC'
    e.start_datetime = '2012-03-09T03:09:00+09:00'
    expect(e.tz_min).to eq 0
    expect(e.timezone.utc_offset).to eq 0
  end

  it "changes tz_min by setting time zone" do
    e = an_event
    e.timezone = 'UTC'
    expect(e.tz_min).to eq 0
    e.timezone = 'Asia/Tokyo'
    expect(e.tz_min).to eq 540
  end

  it ": Term string formatting" do
    e = an_event
    now = DateTime.now
    e.start_datetime = now
    e.end_datetime   = now
    e.allday = false
    expect(e.term_str).to eq(now.strftime("%m-%d %H:%M"))

    e.allday = true
    expect(e.term_str).to eq(now.strftime("%m-%d"))

    e.allday = false
    e.start_datetime = Time.new(2010, 3, 9, 15, 9)
    e.end_datetime   = Time.new(2010, 3, 9, 17, 9)
    expect(e.term_str).to eq("2010-03-09 15:09 - 17:09")

    e.allday = true
    expect(e.term_str).to eq("2010-03-09")

    e.allday = false
    e.end_datetime   = Time.new(2010, 3, 11, 15, 9)
    expect(e.term_str).to eq("2010-03-09 15:09 - 2010-03-11 15:09")

    e = an_event
    e.allday = true
    e.start_datetime = Time.new(2010, 3, 11, 0, 0)
    e.end_datetime   = Time.new(2010, 3, 12, 0, 0)
    expect(e.term_str).to eq("2010-03-11")
  end

  it "endtime must be treated as open interval: [start, end)" do
    e = an_event
    e.allday = true

    e.start_date     = Date.new(2010, 3, 9)
    e.end_date       = Date.new(2010, 3, 10)
    expect(e.term_str).to eq("2010-03-09")

    e.start_datetime = Date.new(2010, 3, 9)
    e.end_datetime   = Date.new(2010, 3, 10)
    expect(e.term_str).to eq("2010-03-09")

    e.start_datetime = Date.new(2010, 3, 9)
    e.end_datetime   = Date.new(2010, 3, 11)
    expect(e.term_str).to eq("2010-03-09 - 2010-03-10")

    e.start_date     = Date.new(2010, 3, 9)
    e.end_date       = Date.new(2010, 3, 11)
    expect(e.term_str).to eq("2010-03-09 - 2010-03-10")

    e.start_datetime = Time.new(2010, 3, 9, 15, 9)
    e.end_datetime   = Time.new(2010, 3, 10, 15, 9)
    expect(e.term_str).to eq("2010-03-09 - 2010-03-10")

    e.start_date     = Time.new(2010, 3, 9, 15, 9)
    e.end_date       = Time.new(2010, 3, 10, 15, 9)
    expect(e.term_str).to eq("2010-03-09")

    e.end_datetime   = Time.new(2010, 3, 12, 15, 9)
    expect(e.term_str).to eq("2010-03-09 - 2010-03-12")

    e.end_datetime   = Date.new(2010, 3, 12)
    expect(e.term_str).to eq("2010-03-09 - 2010-03-11")
  end

  it "can be changed time only by set {start,end}_time " do
    e = an_event
    keepdate = e.start_date
    e.start_time = "12:30"
    expect(e.start_date).to eq keepdate

    e.start_date = "2012-03-09"
    expect(e.start_time).to eq "00:00"
    e.start_time = "03:09"
    expect(e.start_datetime).to eq Time.new(2012, 3, 9, 3, 9, 0).to_datetime
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
    expect(e.g_html_link).to   eq(google_input["htmlLink"])
    expect(e.status).to        eq(google_input["status"])
    expect(e.etag).to          eq(google_input["etag"])
    expect(e.ical_uid).to      eq(google_input["iCalUID"])
    expect(e.g_calendar_id).to eq('dummy_gcal_id')
    expect(e.created_at).to    eq(google_input["created"])

    e.save!
    expect(Event.find(e.id).created_at).to eq(google_input["created"])

    output = e.to_exfmt :google_v3
    #pending "Not yet decided to add 'id' for google sync" do
    #  output[:id].should == google_input[:id]
    #end
    %w(summary status start end recurrence iCalUID recurringEventId).each do |f|
      expect(output[f]).to eq(google_input[f])
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
      expect(output[f]).to eq(google_input[f])
    end

    expect(output[:start][:dateTime]).to eq(google_input[:start][:dateTime])
    expect(output[:start][:timeZone]).to eq(google_input[:start][:timeZone])
    expect(output[:end][:dateTime]).to eq(google_input[:end][:dateTime])
    expect(output[:end][:timeZone]).to eq(google_input[:end][:timeZone])
    expect(output[:originalStartTime][:dateTime]).to eq(google_input[:originalStartTime][:dateTime])
    expect(output[:originalStartTime][:timeZone]).to eq(google_input[:originalStartTime][:timeZone])

    google_input[:start] = Hashie::Mash.new({:date => Date.parse("2012-03-09")})
    google_input[:end]   = Hashie::Mash.new({:date => Date.parse("2012-03-10")})
    google_input[:originalStartTime] = Hashie::Mash.new({:date => Date.parse("2012-03-03")})
    e = an_event
    e.load_exfmt :google_v3, google_input, :calendar_id => 'dummy_gcal_id'
    output = e.to_exfmt :google_v3
    expect(output[:originalStartTime]).to eq(google_input[:originalStartTime])
    expect(output[:originalStartTime][:date]).to eq(google_input[:originalStartTime][:date])
  end

  it "saves extra tags" do
    e = an_event
    e.tag_names = %w(should keep ordinal tags)
    expect(e.extra_tags[:hoge]).to eq []
    expect(e.extra_tags[:hoge]).to be_a(Event::ExtraTagContainer::TagContainer)
    e.extra_tags[:ext1].names_str = "hoge fuga/funya"
    expect(e.extra_tags[:ext1].names).to eq %w(hoge fuga funya)
    e.extra_tags[:ext2].names_str = "a"
    expect(e.extra_tags[:ext2].names).to eq %w(a)
    expect(e.extra_tags[:ext1].names).to eq %w(hoge fuga funya)
    e.save!
    en = Event.find(e.id)
    expect(en.extra_tags[:ext1].names).to eq %w(hoge fuga funya)
    expect(en.tag_names).to eq %w(should keep ordinal tags)

    e.extra_tags[:ext1].names = %w(z 1)
    expect(e.extra_tags[:ext1].names).to eq %w(z 1)
    e.extra_tags[:ext2].names = %w(z 2 1)
    expect(e.extra_tags[:ext2].names).to eq %w(z 2 1)
    e.save!

    en = Event.find(e.id)
    expect(en.extra_tags[:ext1].names).to eq %w(z 1)
    expect(en.extra_tags[:ext2].names).to eq %w(z 2 1)
    expect(en.extra_tag_relations.size).to eq(5)
    expect(en.tag_names).to eq %w(should keep ordinal tags)

  end

  it "should accept single string as extra tag name" do
    e = an_event
    e.extra_tags[:hoge].names = "simple tag name"
    expect(e.extra_tags[:hoge].names).to eq ["simple_tag_name"]
  end

  it "replaces space in tag name" do
    e = an_event
    e.tag_names = ["Hellow, World", "Good      Bye"]
    expect(e.tag_names).to eq ["Hellow,_World", "Good_Bye"]
    expect(e.tags[0].name).to eq "Hellow,_World"
    expect(e.tags[1].name).to eq "Good_Bye"
  end

  it "respond recurring_instance?" do
    e = an_event
    expect(e.recurring_instance?).to be false
    e.g_recurring_event_id = "abcdef"
    expect(e.recurring_instance?).to be_truthy
    e.g_recurring_event_id = nil
    expect(e.recurring_instance?).to be_falsey
    e.g_recurring_event_id = ""
    expect(e.recurring_instance?).to be_falsey
  end

  it "generates etag automatically" do
    e = an_event
    expect(e.etag).to be_blank
    e.save!
    expect(e.etag).not_to be_blank
  end

  it "changes etag when attribute updates" do
    e = an_event
    e.save!
    prev_etag = e.etag
    e.summary = "test"
    expect(e.etag).to eq prev_etag
    e.save!
    expect(e.etag).not_to eq prev_etag
    expect(e.etag).not_to be_blank
  end

  it "acceept conditional tag name query" do
    e = an_event
    e.tag_names = %w(Tag query test)
    e.save!
    expect(e.tag_names(:name => "Tag")).to eq %w(Tag)

    t1 = Tag.create(:name => "time-#{Time.now.to_i}")
    sleep 1
    t2 = Tag.create(:name => "time-#{Time.now.to_i}")
    e.tag_ids = [t1, t2].map{|t| t.id}
    e.save!

    expect(e.tag_names(:created_at => t1.created_at)).to eq [t1.name]
  end

  it "hides hidden tags when convert to google v3 JSON" do
    e = an_event
    e.tag_names = %w(This is hidden tag test)
    e.save!

    Tag.find_by_name!("hidden").update_attribute :hidden, true
    expect(e.tag_names(:hidden => false)).to eq %w(This is tag test)

    Tag.find_by_name!("test"  ).update_attribute :hidden, true
    expect(e.tag_names(:hidden => false)).to eq %w(This is tag)
  end
end
