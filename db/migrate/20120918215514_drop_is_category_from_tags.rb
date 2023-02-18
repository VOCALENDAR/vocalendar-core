class DropIsCategoryFromTags < ActiveRecord::Migration[5.1]
  def up
    remove_index :tags, :is_category
    remove_column :tags, :is_category
  end

  def down
    add_column :tags, :is_category, :boolean, :null => false, :default => false
    add_index :tags, :is_category
  end
end
