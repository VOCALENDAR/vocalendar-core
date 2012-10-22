# coding: utf-8

class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    @events = Event.paginate(:page => params[:page], :per_page => 50, :include => [:tags,  :uris])
    if params[:tag_id]
      @events = @events.
        joins('inner join events_tags on events.id = events_tags.event_id').
        where('events_tags.tag_id' => params[:tag_id])
    end

    respond_to do |format|
      format.html
      format.xml  { render :xml  => @events }
      format.json {

        # Change to Google JSON
        # TOP level
        calendarid = @events == nil ? 'null' : @events[0].g_calendar_id
        @calendars = Calendar.where('external_id' => calendarid)

        json = {:version => '1.0', :encoding => 'UTF-8'}
        # TODO feed情報
        feed = {

            :xmlns => 'http://www.w3.org/2005/Atom',
            'xmlns$openSearch' => 'http://a9.com/-/spec/opensearchrss/1.0/',
            'xmlns$gCal' => 'http://schemas.google.com/gCal/2005',
            'xmlns$gd' => 'http://schemas.google.com/g/2005',
            :id => 'http://www.google.com/calendar/feeds/' + @calendars[0].external_id + '/public/full',
            :updated => {:$t => @calendars[0].latest_synced_item_updated_at},
            :category => [{ :scheme => 'http://schemas.google.com/g/2005#kind',
                            :term => 'http://schemas.google.com/g/2005#event'
                          }],
            :title => { :$t => @calendars[0].name, :type => 'text'},
            :subtitle => { :$t => '', :type => 'text'},
            :link => [
              { :rel => 'alternate', :type => "text/html", :href => 'https://www.google.com/calendar/embed?src=' + calendarid},
              { :rel => 'http://schemas.google.com/g/2005#feed', :type => 'application/atom+xml', :href => 'https://www.google.com/calendar/feeds/' + calendarid  + '/public/full'},
              { :rel => 'http://schemas.google.com/g/2005#batch', :type => 'application/atom+xml', :href => 'https://www.google.com/calendar/feeds/' + calendarid  + '/public/full/batch'},
              # TODO パラメータ化
              { :rel => 'self', :type => 'application/atom+xml', :href =>'https://www.google.com/calendar/feeds/' + calendarid  + '/public/full?alt=json-in-script&q=cd%E3%80%80&start-index=151&max-results=25&singleevents=true&start-max=2015-09-26T16%3A04%3A16Z&sortorder=ascending&orderby=starttime'},
              { :rel => 'previous', :type => 'application/atom+xml', :href =>'https://www.google.com/calendar/' + calendarid  + '/public/full?alt=json-in-script&q=cd%E3%80%80&start-index=126&max-results=25&singleevents=true&start-max=2015-09-26T16%3A04%3A16Z&sortorder=ascending&orderby=starttime'},
              { :rel => 'next', :type => 'application/atom+xml', :href =>'https://www.google.com/calendar/feeds/' + calendarid  + '/public/full?alt=json-in-script&q=cd%E3%80%80&start-index=176&max-results=25&singleevents=true&start-max=2015-09-26T16%3A04%3A16Z&sortorder=ascending&orderby=starttime'}
            ],
            :author => [ { :name => { :$t => 'editor.vocalendar@gmail.com'}, :email => { :$t => 'editor.vocalendar@gmail.com'}}],
            :generator => { :$t => 'Google Calendar', :version => '1.0', :uri => 'http://www.google.com/calendar'},
            'openSearch$totalResults' => { :$t => @events.size},
            # TODO パラメータ化
            'openSearch$startIndex' => { :$t => 0},
            'openSearch$itemsPerPage' => { :$t => 25},
            'gCal$timezone' => { :value => 'Asia/Tokyo'},
            'gCal$timesCleaned' => { :value => 0},
            'gd$where' => {:valueString => ''},



        }
        # entry( イベント情報 )
        entry = []
        @events.each_with_index { |event, i|

          feedurl = 'http://www.google.com/calendar/feeds/' + event.g_calendar_id + '/public/full/' + event.g_id
          entry[i] = {
                      :id => {:$t => feedurl},
                      :published => {:$t => event.created_at},
                      :updated => {:$t => event.updated_at},
                      :category => [{ :scheme => 'http://schemas.google.com/g/2005#kind',
                                      :term => 'http://schemas.google.com/g/2005#event'
                                    }],
                      :title => {:$t => event.summary, :type => 'text'},
                      :content => {:$t => event.description, :type => 'text'},
                      :link => [
                                  {:rel => 'alternate', :type => 'text/html', :href => event.g_html_link },
                                  {:rel => 'self', :type => 'aplication/atom+xml', :href => feedurl}
                              ],
                      :author => [{:name => {:$t => 'VOCALENDAR # メイン'}}],
                      'gd$comments' => {'gd$feedLink' => {:href => feedurl + '/comments'}},
                      'gd$eventStatus' => { :value => 'http://schemas.google.com/g/2005#event.' + event.status },
                      'gd$where' => [{:valueString => event.location}],
                      'gd$who' => [:email => event.g_creator_email],
                      :rel => 'http://schemas.google.com/g/2005#event.organizer',
                      :valueString => 'VOCALENDAR # メイン',
                      'gd$when' => [
                                  {:endtime => event.end_datetime},
                                  {:startTime => event.start_datetime}
                      ],

                      # original columns
                      :allday => {:$t => event.allday},

          }

        }

        feed[:entry] = entry
        json[:feed] = feed

        render :json => json

      }
    end

  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
    respond_with @event, :include=> [:tags,  :uris]
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    # TODO 回数はとりあえず固定
    2.times { @event.uris.build }
    2.times { @event.tags.build }
    respond_with @event
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    # TODO Googleに一度登録してからデータを流用とか？
    @event.etag='etag'
    @event.ical_uid='ical_uid'
    @event.save
    respond_with @event
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])
    @event.update_attributes(params[:event])
    respond_with @event
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    respond_with @event
  end
end
