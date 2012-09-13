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
    if params[:setting]
      Setting.google_api_client_id = params[:setting][:google_api_client_id]
      Setting.google_api_secret = params[:setting][:google_api_secret]
    end

    redirect_to({:action => Setting.master_auth_email ? :index : :set_master_auth}, :notice => t("admin.update_appid.restart_notice"))
  end

  def set_master_auth
    @auth_info = Setting.master_auth_email
  end

  def auth_callback
    @auth = request.env["omniauth.auth"]
    %w(refresh_token expires_at token).each do |attr|
      Setting.__send__ "master_auth_#{attr}=", @auth["credentials"][attr]
    end
    Setting.master_auth_email = @auth["extra"]["raw_info"]["email"]

    redirect_to({:action => :index}, :notice => t("admin.auth_callback.success"))
  end
end