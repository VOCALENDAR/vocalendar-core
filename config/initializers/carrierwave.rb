CarrierWave.configure do |config|
  config.permissions = 0644
  config.directory_permissions = 0755
  config.cache_dir = "#{Rails.root}/tmp/uploads"
  config.storage = :file

  if Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  end
end
