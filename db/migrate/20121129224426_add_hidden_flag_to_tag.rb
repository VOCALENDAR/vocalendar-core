class AddHiddenFlagToTag < ActiveRecord::Migration
  def change
    add_column :tags, :hidden, :boolean, :default => false, :null => false
  end
end
