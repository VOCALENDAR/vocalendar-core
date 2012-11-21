class AddGoogleUidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :google_uid, :string
  end
end
