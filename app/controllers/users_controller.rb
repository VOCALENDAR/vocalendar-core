class UsersController < ApplicationController
  include VocalendarCore::HistoryUtils::Controller
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
    # 新規追加は画面にはないので正しいかわからないけど、updateと同様のStrong parameter対応しておく。
    @user = User.new(update_params)
    @user.save
    @user.errors.empty? and add_history
    respond_with(@user)
  end

  def update
    #@user.update_attributes(update_params)#, :as => current_user.role)
    @user.update(update_params)#, :as => current_user.role)
    @user.errors.empty? and add_history
    respond_with(@user)
  end

  def destroy
    @user.destroy
    add_history
    respond_with(@user)
  end

  private
    def update_params
      if current_user.admin?
        return params.require(:user).permit(:name, :email, :role)
      end
      params.require(:user).permit(:name, :email)

    end
end
