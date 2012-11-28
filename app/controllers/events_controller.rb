# coding: utf-8
class EventsController < ApplicationController
  load_and_authorize_resource

  before_filter :set_type_variable

  # GET /events
  # GET /events.json
  def index
    @events = @events.page(params[:page]).per(50).order('updated_at desc')
    unless params[:tag_id].blank?
      tids = params[:tag_id]
      String === tids and tids = tids.split(',')
      @events = @events.by_tag_ids(tids)
    end
    params[:g_calendar_id].blank? or
      @events = @events.where(:g_calendar_id => params[:g_calendar_id])
    params[:q].blank? or
      @events = @events.search(params[:q])
    params[:include_delete].blank? and
      @events = @events.active

    respond_with @events, :include=> [:tags]
  end

  # GET /events/1
  # GET /events/1.json
  def show
    respond_with @event, :include=> [:tags]
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
    respond_with @event
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event.update_attributes(params[@type.underscore])
    respond_with @event
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.update_attirbute :status, 'cancelled'
    respond_with @event
  end

  private
  def set_type_variable
    @type = 'Event'
  end
end
