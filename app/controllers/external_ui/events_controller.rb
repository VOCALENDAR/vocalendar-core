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

    respond_with @events, :layout => detect_layout
  end

  def cd_releases
    load_cd_releases
    respond_with @events, :layout => detect_layout
  end

  def cd_releases_body
    load_cd_releases
    respond_with @events, :layout => nil
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

    respond_with @event, :layout => detect_layout
  end

  private
  def detect_layout
    request.xhr? and false
    params[:embed].blank? ? "mainsite_dummy" : "external_ui_embed"
  end

  def load_cd_releases
    pivot = nil
    begin
      pivot = Date.parse(params[:pivot])
    rescue
      pivot = Date.today
    end
    start_date = pivot - 1.month
    start_date = Time.new(start_date.year, start_date.month, 1, 0, 0, 0).to_datetime
    end_date   = pivot + 2.month
    end_date   = Time.new(end_date.year, end_date.month, 1, 0, 0, 0).to_datetime
    @events = Event.active.reorder('start_datetime').
      where("start_datetime >= ?", start_date).
      where("start_datetime < ?",  end_date).
      joins(:tags).where("tags.name" => "CD")
    @start_date = start_date
    @end_date   = end_date
    @pivot_date = pivot
  end

end
