if File.readable? "#{Rails.root}/tmp/google-api-client-info"
  client_info = IO.readlines "#{Rails.root}/tmp/google-api-client-info"
  client_id = client_info[0].chomp
  client_sec = client_info[1].chomp
  if !client_id.blank? && !client_sec.blank?
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :google_oauth2, client_id, client_sec, {
        access_type: 'offline',
        scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/calendar',
        # redirect_uri:'http://localhost:3000/auth/google_oauth2/callback'
      }
    end
  end
end
