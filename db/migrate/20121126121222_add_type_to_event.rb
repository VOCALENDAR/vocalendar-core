class AddTypeToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :type, :string, :default => '', :null => false
    add_index  :events, :type
  end
end
