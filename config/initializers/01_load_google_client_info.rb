Rails.configuration.google_client_configured = false

begin
  gsetting = YAML.load_file "#{Rails.root}/config/google-api.yml"
  gsetting["client_id"].blank?     and raise
  gsetting["client_secret"].blank? and raise

  Rails.configuration.google_client_id     = gsetting["client_id"]
  Rails.configuration.google_client_secret = gsetting["client_secret"]
  Rails.configuration.google_client_configured = true
rescue
  # ignore
end

Rails.configuration.google_client_configured or
  $stderr.puts "Google API client is not configured!\nSet your client information at #{Rails.root}/config/google-api.yml."
