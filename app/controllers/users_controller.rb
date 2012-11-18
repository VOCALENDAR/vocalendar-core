class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    respond_with(@users)
  end

  def show
    respond_with(@user)
  end

  def new
    respond_with(@user)
  end

  def edit
  end

  def create
    @user = User.new(params[:user], :as => current_user.role)
    @user.save
    respond_with(@user)
  end

  def update
    @user.update_attributes(params[:user], :as => current_user.role)
    respond_with(@user)
  end

  def destroy
    @user.destroy
    respond_with(@user)
  end
end
