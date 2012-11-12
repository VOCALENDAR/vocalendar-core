desc ""
task :cleanup_unused_tags => :environment do
  Tag.all.each do |tag|
    tag.events.count > 0 and next
    Rails.logger.info "Removing unused tag #{tag.name}"
    tag.destroy
  end
end
