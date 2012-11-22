class ExternalUi::EventsController < ApplicationController
  authorize_resource
  layout false

  def index
    @events = Event.page(params[:page]).per(50)
    if params[:tag_id]
      @events = @events.
        joins('inner join event_tag_relations on events.id = event_tag_relations.event_id').
        where('event_tag_relations.tag_id' => params[:tag_id])
    end
    if params[:q]
      @events = @events.search(params[:q])
    end
    respond_with @events
  end

  def show
    if params[:id]
      @event = Event.find params[:id]
    elsif params[:gid]
      @event = Event.find_by_g_id! params[:gid]
    elsif params[:eid]
      @event = Event.find_by_g_eid! params[:eid]
    elsif params[:uid]
      @event = Event.find_by_ical_uid! params[:uid]
    end

    respond_with @event
  end
end
