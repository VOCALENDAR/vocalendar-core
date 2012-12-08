class ExternalUi::ReleaseEventsController < ApplicationController

  layout "mainsite_dummy"
  
  def index
    
    # Recommendの取得
    
    # Recommendデータが無い場合にはとりあえず先頭２件
    @recommends = ReleaseEvent.active.order('start_datetime').
      page(params[:page]).per( 2 )
    
    
    @releases = ReleaseEvent.active.order('start_datetime').
      page(params[:page]).per( 3 * 5 ).
      where("start_datetime >= ?", DateTime.now - 3.day)

      # んー、このorが理解できない・・・。if文の代わりなんだろうけど。
      params[:tag_id].blank? or
        @releases = @releases.by_tag_ids(params[:tag_id])

      respond_with @releases
  end

  def show
    @release = ReleaseEvent.active.find(params[:id])
    respond_with @release
  end
  
end
