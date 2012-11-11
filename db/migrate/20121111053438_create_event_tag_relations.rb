class CreateEventTagRelations < ActiveRecord::Migration
  def up
    create_table :event_tag_relations do |t|
      t.references :event
      t.references :tag
      t.integer :pos, :null => false, :default => 1
      t.string :target_field
      t.text :uri
    end
    add_index :event_tag_relations, :event_id
    add_index :event_tag_relations, :tag_id

    execute "insert into event_tag_relations (event_id, tag_id) select event_id, tag_id from events_tags"
    drop_table :events_tags
  end

  def down
    create_table :events_tags, :id => false do |t|
      t.integer :event_id
      t.integer :tag_id
    end
    add_index :events_tags, [:event_id, :tag_id]
    add_index :events_tags, [:tag_id, :event_id]

    execute "insert into events_tags select distinct event_id, tag_id from event_tag_relations"

    drop_table :event_tag_relations
  end
end
