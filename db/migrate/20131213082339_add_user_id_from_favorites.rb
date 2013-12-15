class AddUserIdFromFavorites < ActiveRecord::Migration
  def change
    add_column :favorites, :event_id, :integer
    add_column :favorites, :user_id, :integer
  end
end
