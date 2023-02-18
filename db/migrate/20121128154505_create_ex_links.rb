class CreateExLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :ex_links do |t|
      t.string :type
      t.string :name
      t.text :uri
      t.string :remote_id

      t.timestamps
    end
    add_index :ex_links, [:type, :remote_id]

    create_table :tags_ex_links, :id => false do |t|
      t.integer :tag_id
      t.integer :ex_link_id
    end
    add_index :tags_ex_links, :tag_id
    add_index :tags_ex_links, :ex_link_id

    create_table :events_ex_links, :id => false do |t|
      t.integer :event_id
      t.integer :ex_link_id
    end
    add_index :events_ex_links, :event_id
    add_index :events_ex_links, :ex_link_id
  end
end
