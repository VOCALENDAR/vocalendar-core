# coding: utf-8

class GoogleResponder < ActionController::Responder

  def to_json

    puts 'to_json'
    puts options

    # Google互換を指定されていなければディフォルトのJSONを出力
    if options[:type] != 'Google'
      to_format
      return
    end

    # Change to Google JSON
    # TOP level
    @events = @resource
    calendarid = @events == nil ? 'null' : @events[0].g_calendar_id
    @calendars = Calendar.where('external_id' => calendarid)
    @calendar = @calendars == nil ? 'null' : @calendars[0]
    feeduri = 'http://www.google.com/calendar/feeds/' + @calendar.external_id + '/public/full'

    json = {:version => '1.0', :encoding => 'UTF-8'}
    # TODO feed情報
    feed = {

        :xmlns => 'http://www.w3.org/2005/Atom',
        'xmlns$openSearch' => 'http://a9.com/-/spec/opensearchrss/1.0/',
        'xmlns$gCal' => 'http://schemas.google.com/gCal/2005',
        'xmlns$gd' => 'http://schemas.google.com/g/2005',
        :id => feeduri,
        :updated => {:$t => @calendar.latest_synced_item_updated_at},
        :category => [{ :scheme => 'http://schemas.google.com/g/2005#kind',
                        :term => 'http://schemas.google.com/g/2005#event'
                      }],
        :title => { :$t => @calendar.name, :type => 'text'},
        :subtitle => { :$t => '', :type => 'text'},
        :link => [
          { :rel => 'alternate', :type => "text/html", :href => 'https://www.google.com/calendar/embed?src=' + calendarid},
          { :rel => 'http://schemas.google.com/g/2005#feed', :type => 'application/atom+xml', :href => feeduri},
          { :rel => 'http://schemas.google.com/g/2005#batch', :type => 'application/atom+xml', :href => feeduri + '/batch'},
          # TODO パラメータ化
          { :rel => 'self', :type => 'application/atom+xml', :href => feeduri + '?alt=json-in-script'},
          #{ :rel => 'previous', :type => 'application/atom+xml', :href =>'https://www.google.com/calendar/' + calendarid  + '/public/full?alt=json-in-script&q=cd%E3%80%80&start-index=126&max-results=25&singleevents=true&start-max=2015-09-26T16%3A04%3A16Z&sortorder=ascending&orderby=starttime'},
          #{ :rel => 'next', :type => 'application/atom+xml', :href =>'https://www.google.com/calendar/feeds/' + calendarid  + '/public/full?alt=json-in-script&q=cd%E3%80%80&start-index=176&max-results=25&singleevents=true&start-max=2015-09-26T16%3A04%3A16Z&sortorder=ascending&orderby=starttime'}
        ],
        :author => [ { :name => { :$t => 'editor.vocalendar@gmail.com'}, :email => { :$t => 'editor.vocalendar@gmail.com'}}],
        :generator => { :$t => 'Google Calendar', :version => '1.0', :uri => 'http://www.google.com/calendar'},
        'openSearch$totalResults' => { :$t => @events.size},
        # TODO パラメータ化
        'openSearch$startIndex' => { :$t => 0},
        'openSearch$itemsPerPage' => { :$t => @events.size},
        'gCal$timezone' => { :value => 'Asia/Tokyo'},
        'gCal$timesCleaned' => { :value => 0},
        'gd$where' => {:valueString => ''},



    }
    # entry( イベント情報 )
    entry = []
    @events.each_with_index { |event, i|

      eventfeedurl = 'http://www.google.com/calendar/feeds/' + event.g_calendar_id + '/public/full/' + event.g_id
      entry[i] = {
                  :id => {:$t => eventfeedurl },
                  :published => {:$t => event.created_at},
                  :updated => {:$t => event.updated_at},
                  :category => [{ :scheme => 'http://schemas.google.com/g/2005#kind',
                                  :term => 'http://schemas.google.com/g/2005#event'
                                }],
                  :title => {:$t => event.summary, :type => 'text'},
                  :content => {:$t => event.description, :type => 'text'},
                  :link => [
                              {:rel => 'alternate', :type => 'text/html', :href => event.g_html_link },
                              {:rel => 'self', :type => 'aplication/atom+xml', :href => eventfeedurl}
                          ],
                  :author => [{:name => {:$t => @calendar.name}}],
                  'gd$comments' => {'gd$feedLink' => {:href => eventfeedurl + '/comments'}},
                  'gd$eventStatus' => { :value => 'http://schemas.google.com/g/2005#event.' + event.status },
                  'gd$where' => [{:valueString => event.location}],
                  'gd$who' => [:email => event.g_creator_email],
                  :rel => 'http://schemas.google.com/g/2005#event.organizer',
                  :valueString => @calendar.name,
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



  end


end