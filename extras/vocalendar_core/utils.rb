module VocalendarCore
  class GoogleAPIError < StandardError
    def initialize(result, msg)
      @api_result = result
      super(msg)
    end
    attr_accessor :api_result
  end
  
  module Utils
    def update_gapi_client_token(gac)
      gac.authorization.expired? or return
      logger.debug "Google API: access token has been expired, trying refresh..."
      auth = gac.authorization
      auth.fetch_access_token!
      Setting.transaction do
        Setting.master_auth_expires_at = auth.expires_at.to_i
        Setting.master_auth_issued_at = auth.issued_at.to_i
        Setting.master_auth_token = auth.access_token
        Setting.master_auth_refresh_token = auth.refresh_token
      end
      logger.debug "Google API: access token refresh success."
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

    def gapi_request(method, params = {}, body = nil)
      client = gapi_client
      service = client.discovered_api('calendar', 'v3')
      greq = {
        :headers => {'Content-Type' => 'application/json'},
        :api_method => service.events.__send__(method),
        :parameters => {}.merge(params),
      }
      body and greq[:body] = body
      greq_orig = greq.dup
      logger.debug "Execute Google API request #{greq[:api_method].id}"
      result = client.execute(greq)
      if result.status < 200 || result.status >= 300
        msg = "Error on Google calendar API '#{method}': status=#{result.status}, request=#{greq_orig.inspect} response=#{result.body}"
        logger.error msg
        #logger.error result.inspect
        raise GoogleAPIError.new(result, msg)
      end
      logger.debug "API request #{greq[:api_method].id} success (status=#{result.status})"
      result
    end
  end
end
