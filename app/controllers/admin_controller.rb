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
    open("#{Rails.root}/tmp/google-api-client-info", "w", 0600) do |f|
      f.puts params[:setting][:google_api_client_id]
      f.puts params[:setting][:google_api_secret]
    end
    redirect_to({:action => Setting.master_auth_uid ? :index : :set_master_auth}, :notice => t("admin.update_appid.restart_notice"))
  end

  def set_master_auth
    @auth_info = Setting.master_auth_uid
  end

  def auth_callback
    @auth = request.env["omniauth.auth"]
    Setting.transaction do
      %w(refresh_token expires_at token).each do |attr|
        Setting.__send__ "master_auth_#{attr}=", @auth["credentials"][attr]
      end
      Setting.master_auth_issued_at = Time.now.to_i
      Setting.master_auth_uid = @auth.uid
    end

    redirect_to({:action => :index}, :notice => t("admin.auth_callback.success"))
  end
end
