class HistoriesController < ApplicationController
  load_and_authorize_resource
  def index
    @histories = @histories.page(params[:page]).per(150)
    params[:target] and
      @histories = @histories.where(:target => params[:params])
    params[:user_id] and
      @histories = @histories.where(:user_id => params[:user_id])

    respond_with(@histories)
  end
end
