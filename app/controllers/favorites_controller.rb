class FavoritesController < ApplicationController

  load_and_authorize_resource

  # GET /events/:event_id/favorite
  # GET /events/:event_id/favorite.json
  def show
    respond_with Favorite.where(:user_id => current_user.id, :event_id => params[:event_id])
    #respond_with @Favorite
  end

end
