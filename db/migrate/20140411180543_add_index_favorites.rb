class AddIndexFavorites < ActiveRecord::Migration[5.1]
  def change
    add_index :favorites, [:event_id, :user_id]
    add_index :favorites, :user_id
  end
end
