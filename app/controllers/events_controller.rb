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
        # 試してみた。
        render :json => {:items =>[{:event=> "あ", :time=>"2012-12-02"}, {:event=> "あ", :time=>"2012-12-03"}] }

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
