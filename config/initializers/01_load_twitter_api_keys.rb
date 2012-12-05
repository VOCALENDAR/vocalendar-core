Rails.configuration.twitter_api_key_configured = false

begin
  twsetting = YAML.load_file "#{Rails.root}/config/twitter-api.yml"
  twsetting["consumer_key"].blank?    and raise
  twsetting["consumer_secret"].blank? and raise

  Rails.configuration.twitter_consumer_key       = twsetting["consumer_key"]
  Rails.configuration.twitter_consumer_secret    = twsetting["consumer_secret"]
  Rails.configuration.twitter_api_key_configured = true
rescue
  # ignore
end

Rails.configuration.twitter_api_key_configured or
  $stderr.puts "Google API client is not configured!\nSet your client information at #{Rails.root}/config/google-api.yml."
