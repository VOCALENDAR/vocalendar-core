class FavoritesController < ApplicationController

  load_resource

  # GET /events/:event_id/favorite
  # GET /events/:event_id/favorite.json
  def show
    respond_with favorites.first!
  end

  # PUT /events/:event_id/favorite
  # PUT /events/:event_id/favorite.json
  def update
    # @favoriteでとれないのはなぜじゃらほい
    @favorite = favorites.first_or_initialize
    @favorite.value = params[:value] ? params[:value] : 1
    @favorite.save
    respond_with @favorite
  end
  
  # DELETE /events/:event_id/favorite
  # DELETE /events/:event_id/favorite.json
  def destroy
    respond_with favorites.first!.destroy
  end
  
  # TODO move model
  private
    def favorites
      Favorite.where(:user_id => current_user.id, :event_id => params[:event_id])
      # for test
      # Favorite.where(:user_id => 9, :event_id => params[:event_id])
    end
  
end
