# coding: utf-8
class EventsController < ApplicationController
  include VocalendarCore::HistoryUtils::Controller
  load_and_authorize_resource

  before_filter :set_type_variable

  # GET /events
  # GET /events.json
  def index
    
    @events = @events.page(params[:page]).per(params[:limit].blank? ? 50 : [params[:limit].to_i, 50].min ).order('updated_at desc')
    unless params[:tag_id].blank?
      tids = params[:tag_id]
      String === tids and tids = tids.split(',')
      @events = @events.by_tag_ids(tids)
    end
    params[:g_calendar_id].blank? or
      @events = @events.where(:g_calendar_id => params[:g_calendar_id])
    params[:startTime].blank? or
      @events = @events.where('start_datetime >= ?', params[:startTime])
    params[:endTime].blank? or
    @events = @events.where('end_datetime <= ?', params[:endTime])
    params[:q].blank? or
      @events = @events.search(params[:q])
    params[:include_delete].blank? and
      @events = @events.active
      
    

      
    puts 'index'
    respond_with @events, :include=> [:tags, :related_links],
                :responder => GoogleResponder, :type => params[:type], :callback=>params[:callback]
  end

  # GET /events/1
  # GET /events/1.json
  def show
    respond_with @event, :include=> [:tags, :related_links], :callback=>params[:callback]
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
    @event.save
    @event.errors.empty? and add_history
    respond_with @event
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event.update_attributes(params[@type.underscore])
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


  def favorites
    Favorite.where(:user_id => 9, :event_id => params[:event_id])
    #Favorite.where(:user_id => current_user.id, :event_id => params[:event_id])
  end

end
