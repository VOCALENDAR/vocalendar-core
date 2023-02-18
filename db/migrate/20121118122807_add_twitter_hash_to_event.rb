class AddTwitterHashToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :twitter_hash, :string
    add_index :events, :twitter_hash
  end
end
