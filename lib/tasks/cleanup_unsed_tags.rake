# -*- ruby -*-
desc "Remove tags that have no events"
task :cleanup_unused_tags => :environment do
  Tag.cleanup_unused_tags
end
