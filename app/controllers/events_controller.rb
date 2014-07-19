# coding: utf-8
class EventsController < ApplicationController
  include VocalendarCore::HistoryUtils::Controller
  #load_and_authorize_resource
  load_resource except: [:create]

  before_filter :set_type_variable

  # GET /events
  # GET /events.json
  def index

    # TODO 総ページ数が必要じゃない？
    @events = @events.includes(:tags).references(:tags)
    if params[:minInfo].blank?
      @events = @events.includes(:related_links).references(:related_links)
      @events = @events.includes(:favorites).references(:favorites)
      if !params[:favorites].blank? and user_signed_in?
        @events = @events.where(favorites: {user_id: current_user.id})
      end
    end

    sortString = if params[:order].blank?
      'events.start_datetime asc, events.allday desc' else 'events.updated_at desc' end
    @events = @events.page(params[:page]).per(params[:limit].blank? ? 50 : [params[:limit].to_i, 50].min ).order(sortString)
    unless params[:tag_id].blank?
      tids = params[:tag_id]
      String === tids and tids = tids.split(',')
      @events = @events.by_tag_ids(tids)
    end
    params[:g_calendar_id].blank? or
      @events = @events.where(:g_calendar_id => params[:g_calendar_id])

    params[:startTime].blank? or
      @events = @events.where('( allday=? and end_date > ? ) or ( allday=? and end_datetime >= ? )', true, toDate(Date, params[:startTime]), false, toDate(DateTime, params[:startTime]))
    params[:endTime].blank? or
      @events = @events.where('( allday=? and start_date <= ? ) or ( allday=? and start_datetime <= ? )', true, toDate(Date, params[:endTime]), false, toDate(DateTime, params[:endTime]))

        
    params[:q].blank? or
      @events = @events.search(params[:q])
    params[:include_delete].blank? and
      @events = @events.active

    respond_with @events
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event
          .includes(:tags).references(:tags)
          .includes(:related_links).references(:related_links)
          .includes(:favorites).references(:favorites)
          .where(id: params[:id]).first!
    respond_with @event
  end
  
  # GET /events/new
  # GET /events/new.json
  def new
    respond_with @event
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(update_params)
    @event.save
    @event.errors.empty? and add_history
    respond_with @event
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event.update(update_params)
    @event.errors.empty? and add_history
    respond_with @event
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.status = 'cancelled'
    add_history
    respond_with @event
  end

  private
  def set_type_variable
    @type = 'Event'
  end

  private
  def update_params
    # TODO @typeの使い方
    #params[@type.underscore].require(:event).permit(:summary, :tag_name_str, :locaton, :uri,
    params.require(:event).permit(:summary, :tag_names_str, :location, :uri,
                                  :twitter_hash, :start_date, :start_time,
                                  :allday, :end_date, :end_time, :remove_image,
                                  :description)
  end

  FORMAT = ["%Y-%m-%dT%H:%M:%S%z", "%Y/%m/%dT%H:%M:%S%z"]
  def toDate(clazz, s)
    
    # 日付のみなら時間を足す
    s.length > 10 or s.concat("T00:00:00")
    # 日付・時間のみならタイムゾーン（日本は+9:00）を足す
    s.length > 19 or s.concat("+9:00")
    
    parsed = nil
    FORMAT.each do |format|
      begin
        parsed = clazz.strptime(s, format)
        break
      rescue ArgumentError
      end
    end 
    return parsed
  end
    
    
end
