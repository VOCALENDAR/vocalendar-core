class HistoriesController < ApplicationController
  load_and_authorize_resource
  def index
    params.keys.each do |k|
      k =~ /(.*)_id$/ or next
      params[:target] = $1
      params[:id] = params[k]
    end
    logger.debug "Modified params: #{params.inspect}"

    @histories = @histories.page(params[:page]).per(100)
    unless params[:target].blank?
      @histories = @histories.where(:target => params[:target])
      params[:id].blank? or
        @histories = @histories.where(:target_id => params[:id])
    end

    params[:user_id].blank? or
      @histories = @histories.where(:user_id => params[:user_id])

    respond_with(@histories)
  end
end
