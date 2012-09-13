Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Setting.google_api_client_id, Setting.google_api_secret, {
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/calendar',
    # redirect_uri:'http://localhost:3000/auth/google_oauth2/callback'
  }
end
