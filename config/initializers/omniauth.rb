if Rails.configuration.google_client_configured
  client_id     = Rails.configuration.google_client_id
  client_secret = Rails.configuration.google_client_secret

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, client_id, client_secret, {
      access_type: 'offline',
      scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/calendar',
      # redirect_uri:'http://localhost:3000/auth/google_oauth2/callback'
    }
  end
end
