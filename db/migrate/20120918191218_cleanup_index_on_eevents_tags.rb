class CleanupIndexOnEeventsTags < ActiveRecord::Migration
  def up
    remove_index :events_tags, [:tag_id, :event_id]
    remove_index :events_tags, [:event_id, :tag_id]
    add_index :events_tags, :tag_id
    add_index :events_tags, :event_id
  end

  def down
    remove_index :events_tags, :tag_id
    remove_index :events_tags, :event_id
    add_index :events_tags, [:tag_id, :event_id]
    add_index :events_tags, [:event_id, :tag_id]
  end
end
