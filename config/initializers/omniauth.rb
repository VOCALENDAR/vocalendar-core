Rails.configuration.google_client_configured = false

begin
  gsetting = YAML.load_file "#{Rails.root}/config/google-api.yml"
  gsetting["client_id"].blank?  and raise Errno::ENOENT
  gsetting["api_secret"].blank? and raise Errno::ENOENT

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, gsetting["client_id"], gsetting["api_secret"], {
      access_type: 'offline',
      scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/calendar',
      # redirect_uri:'http://localhost:3000/auth/google_oauth2/callback'
    }
    Rails.configuration.google_client_configured = true
  end
rescue Errno::ENOENT
  # ignore
end
