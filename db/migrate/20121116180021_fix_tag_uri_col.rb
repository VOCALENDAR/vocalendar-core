class FixTagUriCol < ActiveRecord::Migration[5.1]
  def up
    add_column :tags, :uri, :text
    remove_column :event_tag_relations, :uri
  end

  def down
    remove_column :tags, :uri
    add_column :event_tag_relations, :uri, :text
  end
end
