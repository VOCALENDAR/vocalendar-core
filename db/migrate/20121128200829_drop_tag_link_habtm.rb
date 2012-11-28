class DropTagLinkHabtm < ActiveRecord::Migration
  def up
    drop_table :ex_links_tags
  end

  def down
    create_table :ex_links_tags, :id => false do |t|
      t.integer :tag_id
      t.integer :ex_link_id
    end
    add_index :ex_links_tags, :tag_id
    add_index :ex_links_tags, :ex_link_id
  end
end
