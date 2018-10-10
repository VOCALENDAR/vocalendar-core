class ExternalUi::ReleaseEventsController < ApplicationController

  layout "mainsite_dummy"

  def index

    # Recommendの取得

    # Recommendデータが無い場合にはとりあえず先頭２件
    @recommends = ReleaseEvent.active.order('start_datetime').
      page(params[:page]).per( 2 ).
      where("start_datetime >= ?", DateTime.now - 5.day)
    params[:tag_id].blank? or
      @recommends = @recommends.by_tag_ids(params[:tag_id])

    @releases = ReleaseEvent.active.order('start_datetime').
      page(params[:page]).per( 3 * 5 ).
      where("start_datetime >= ?", DateTime.now - 3.day)

      params[:tag_id].blank? or
        @releases = @releases.by_tag_ids(params[:tag_id])

      respond_with @releases
  end

  def show
    @release = ReleaseEvent.active.find(params[:id])
    respond_with @release
  end

end
