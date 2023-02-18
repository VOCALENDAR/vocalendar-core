class AddDisabledFlagToExLink < ActiveRecord::Migration[5.1]
  def change
    add_column :ex_links, :disabled, :boolean, :default => false, :null => false
  end
end
