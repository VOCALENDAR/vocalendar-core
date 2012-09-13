class ApplicationController < ActionController::Base
  protect_from_forgery
  self.responder = AppResponder
  respond_to :html, :xml, :json

  def gapi_client
    @gapi_client and return @gapi_client
    gac = Google::APIClient.new
    gac.authorization.access_token = {
      'expires' => true,
      'token' => Setting.master_auth_token,
      'refresh_token' => Setting.master_auth_refresh_token,
      'expires_at' => Setting.master_auth_expires_at.to_i,
    }
    @gapi_client = gac
  end
end
