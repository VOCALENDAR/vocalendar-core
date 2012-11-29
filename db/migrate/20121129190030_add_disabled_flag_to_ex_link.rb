class AddDisabledFlagToExLink < ActiveRecord::Migration
  def change
    add_column :ex_links, :disabled, :boolean, :default => false, :null => false
  end
end
