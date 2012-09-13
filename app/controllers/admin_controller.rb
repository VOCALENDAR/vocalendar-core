class AdminController < ApplicationController
  def index
    if !Setting.google_api_client_id || !Setting.google_api_secret
      redirec_to :action => :set_appid
    end
  end

  def set_appid
    s = Struct.new(:google_api_client_id, :google_api_secret)
    @setting = s.new(Setting.google_api_client_id, Setting.google_api_secret)
  end

  def update_appid
    Setting.google_api_client_id = params[:setting][:google_api_client_id]
    Setting.google_api_secret = params[:setting][:google_api_secret]

    redirect_to :action => Setting.google_api_master_auth ? :index : :set_master_auth
  end

  def set_master_auth
    
  end

  def update_master_auth
  end


end
