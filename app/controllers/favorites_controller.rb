class FavoritesController < ApplicationController

  #load_and_authorize_resource
  load_resource

  # GET /events/:event_id/favorite
  # GET /events/:event_id/favorite.json
  def show
    respond_with favorites.first!
  end

  # POST /events/:event_id/favorite
  # POST /events/:event_id/favorite.json
  def create
    # @favoriteでとれないのはなぜじゃらほい

    @favorite = favorites.first_or_initialize
    @favorite.value = params[:value] ? params[:value] : 1
    @favorite.save
    # TODO 500 internal Server Error で落ちる。 ふぁぼ動作に支障なし
    # NoMethodError (undefined method `favorite_url' for #<FavoritesController:0x6c56718>):
    # app/controllers/application_controller.rb:7:in `respond'
    # app/controllers/favorites_controller.rb:24:in `create'
    # config/initializers/quiet_assets.rb:7:in `call_with_quiet_assets'
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
