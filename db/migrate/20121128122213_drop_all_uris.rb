class DropAllUris < ActiveRecord::Migration
  def up
    drop_table    :uris
    remove_column :events, :primary_uri
    remove_column :tags,   :uri
  end

  def down
    create_table :uris do |t|
      t.text :event_id
      t.text :serviceName
      t.text :uri
      t.text :kind
      t.text :body

      t.timestamps
    end
    add_column :events, :primary_uri, :text
    add_column :tags,   :uri,         :text
  end
end
