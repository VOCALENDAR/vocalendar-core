module VocalendarCore
  module Utils
    def update_gapi_client_token(gac)
      gac.authorization.expired? or return
      auth = gac.authorization
      auth.fetch_access_token!
      Setting.transaction do
        Setting.master_auth_expires_at = auth.expires_at.to_i
        Setting.master_auth_issued_at = auth.issued_at.to_i
        Setting.master_auth_token = auth.access_token
        Setting.master_auth_refresh_token = auth.refresh_token
      end
    end

    def gapi_client
      if @gapi_client
        update_gapi_client_token(@gapi_client)
        return @gapi_client
      end
      gac = Google::APIClient.new
      auth = gac.authorization
      auth.client_id = Setting.google_api_client_id
      auth.client_secret = Setting.google_api_secret
      
      auth.update_token!({
        :access_token => Setting.master_auth_token,
        :refresh_token => Setting.master_auth_refresh_token,
        :expires_in => (Setting.master_auth_expires_at.to_i - Setting.master_auth_issued_at.to_i),
        :issued_at => Time.at(Setting.master_auth_issued_at.to_i),
      })
      update_gapi_client_token(gac)
      @gapi_client = gac
    end
  end
end
