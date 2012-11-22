require 'spec_helper'

describe ExternalUi::EventsController do

  describe "GET 'show'" do
    before(:all) do
      event_attrs = {
        allday: true,
        country: "jp",
        description: "desc\nription",
        end_date: Date.parse("2003-02-27"),
        end_datetime: DateTime.parse("2003-02-27T09:00:00+09:00"),
        etag: "bt6uG7OvVvCre70u9H5QXyrDIXY/Q05qcHhNSGJKaEVBQUFBQUFBQUFBQT09",
        g_calendar_id: "pcg8ct8ulj96ptvqhllgcc181o@group.calendar.google.com",
        g_creator_email: "mizuki.a.ryou@gmail.com",
        g_html_link: "https://www.google.com/calendar/event?eid=M25vN3U1Z2U3NW5zMGNvOWphN21nOWl0anMgcGNnOGN0OHVsajk2cHR2cWhsbGdjYzE4MW9AZw",
        g_id: "3no7u5ge75ns0co9ja7mg9itjs",
        ical_uid: "3no7u5ge75ns0co9ja7mg9itjs@google.com",
        lang: "ja",
        recur_string: "",
        start_date: Date.parse("2003-02-26"),
        start_datetime: DateTime.parse("2003-02-26T09:00:00+09:00"),
        status: "confirmed",
        summary: "YAMAHA VOCALOID",
        tz_min: 540,
      }
      Event.create!(event_attrs)
    end

    it "returns http success" do
      get :index
      response.should be_success
      assigns(:events).should have(1).items
    end

    it "accept search" do
      get :index, :q => 'shoud_not_matched_anything'
      response.should be_success
      assigns(:events).should be_empty
    end

    it "ignore blank search" do
      get :index, :q => ''
      response.should be_success
      assigns(:events).should have(1).items
    end

  end

end