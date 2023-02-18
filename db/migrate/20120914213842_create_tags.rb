class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :name, :null => false, :default => '', :uniq => true
      t.boolean :is_category, :default => false, :null => false
      t.timestamps
    end
    add_index :tags, :name, :unique => true
    add_index :tags, :is_category

    create_table :events_tags, :id => false do |t|
      t.integer :event_id
      t.integer :tag_id
    end
    add_index :events_tags, [:event_id, :tag_id]
    add_index :events_tags, [:tag_id, :event_id]
  end
end
