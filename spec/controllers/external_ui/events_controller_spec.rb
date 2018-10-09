require 'spec_helper'

describe ExternalUi::EventsController do

  describe "GET 'show'" do
    before(:all) do
      event_attrs = {
        allday: true,
        country: "jp",
        description: "desc\nription",
        end_datetime: DateTime.now + 1.day,
        etag: "bt6uG7OvVvCre70u9H5QXyrDIXY/Q05qcHhNSGJKaEVBQUFBQUFBQUFBQT09",
        g_calendar_id: "pcg8ct8ulj96ptvqhllgcc181o@group.calendar.google.com",
        g_creator_email: "testuser@gmail.com",
        g_html_link: "https://www.google.com/calendar/event?eid=M25vN3U1Z2U3NW5zMGNvOWphN21nOWl0anMgcGNnOGN0OHVsajk2cHR2cWhsbGdjYzE4MW9AZw",
        g_id: "3no7u5ge75ns0co9ja7mg9itjs",
        ical_uid: "3no7u5ge75ns0co9ja7mg9itjs@google.com",
        lang: "ja",
        recur_string: "",
        start_datetime: DateTime.now,
        status: "confirmed",
        summary: "YAMAHA VOCALOID",
      }
      Event.create!(event_attrs, :without_protection => true)
    end

    it "returns http success" do
      get :index
      expect(response).to be_success
      expect(assigns(:events).size).to eq(1)
    end

    it "accept search" do
      get :index, params: { :q => 'shoud_not_matched_anything' }
      expect(response).to be_success
      expect(assigns(:events)).to be_empty
    end

    it "ignore blank search" do
      get :index, params: { :q => '' }
      expect(response).to be_success
      ret_with_blank_query = assigns(:events)
      get :index
      expect(response).to be_success
      expect(assigns(:events)).to eq ret_with_blank_query
    end

  end

end
