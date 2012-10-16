class AdminController < ApplicationController
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
end
