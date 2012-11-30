class ExternalUi::EventsController < ApplicationController
  layout "mainsite_dummy"

  def index
    @events = Event.active.order('start_datetime').
      page(params[:page]).per(36).
      where("start_datetime >= ?", DateTime.now - 3.day)
    params[:q].blank? or
      @events = @events.search(params[:q])
    params[:tag_id].blank? or
      @events = @events.by_tag_ids(params[:tag_id])

    respond_with @events
  end

  def show
    ae = Event.active
    if params[:id]
      @event = ae.find params[:id]
    elsif params[:gid]
      @event = ae.find_by_g_id! params[:gid]
    elsif params[:eid]
      @event = ae.find_by_g_eid! params[:eid]
    elsif params[:uid]
      @event = ae.find_by_ical_uid! params[:uid]
    end

    respond_with @event
  end
end
