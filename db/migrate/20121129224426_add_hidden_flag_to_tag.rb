class AddHiddenFlagToTag < ActiveRecord::Migration[5.1]
  def change
    add_column :tags, :hidden, :boolean, :default => false, :null => false
  end
end
