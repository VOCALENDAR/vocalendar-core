namespace :sync_calendar do
  desc "Publish events to google calendar"
  task :publish, [:force] => :environment do |t, args|
    errors = []
    Calendar.where(:io_type => 'dst').each do |cal|
      begin
        cal.sync_events(:force => args[:force])
      rescue => e
        msg = "Failed to publish calendar '#{cal.name}' (##{cal.id}): #{e.class.name}: #{e.to_s} (#{e.backtrace.join(' > ')})"
        Rails.logger.error msg
        errors << "##{cal.id} #{cal.name}: #{e.class.name} #{e.message.sub(/^(.{80}).*/m, '\1...')}"
      end
    end
    errors.empty? or fail "Publish failed on calendar:\n  * #{errors.join("\n  * ")}"
  end
  
  desc "Fetch events from google calendar"
  task :fetch, [:force] => :environment do |t, args|
    errors = []
    Calendar.where(:io_type => 'src').each do |cal|
      begin
        cal.sync_events(:force => args[:force])
      rescue => e
        msg = "Failed to sync calendar '#{cal.name}' (##{cal.id}): #{e.class.name}: #{e.to_s} (#{e.backtrace.join(' > ')})"
        Rails.logger.error msg
        errors << "##{cal.id} #{cal.name}: #{e.class.name} #{e.message.sub(/^(.{80}).*/m, '\1...')}"
      end
    end
    errors.empty? or fail "Fetch failed on calendar: #{errors.join(', ')}"
  end

  desc "Sync all google calendar"
  task :all => [:fetch, :publish]
end

task :sync_calendar => ['sync_calendar:all']

