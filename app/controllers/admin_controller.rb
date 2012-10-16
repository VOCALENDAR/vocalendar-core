class AdminController < ApplicationController
  before_filter :check_gclient_info, :check_master_auth

  def index
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

  private
  def check_gclient_info
    Rails.configuration.google_client_configured and return true
    add_cur_flash_msg :alert, I18n.t("admin.set_appid.missing")
    true
  end

  def check_master_auth
    Setting.master_auth_uid and return true
    add_cur_flash_msg :alert, I18n.t("admin.set_master_auth.notify")
    true
  end
end
