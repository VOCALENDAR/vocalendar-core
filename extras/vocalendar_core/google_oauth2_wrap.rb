require 'omniauth-google-oauth2'

module VocalendarCore
  class GoogleOauth2Wrap < ::OmniAuth::Strategies::GoogleOauth2
    def authorize_params
      super.tap do |params|
        session[:google_oauth2_scope] = params[:scope]
        if params[:scope].include? 'https://www.googleapis.com/auth/calendar'
          params[:access_type] = 'offline'
          params[:approval_prompt] = 'force'
        else
          params.delete :access_type
          params.delete :approval_prompt
        end
      end
    end
  end
end
