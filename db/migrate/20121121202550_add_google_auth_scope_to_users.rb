class AddGoogleAuthScopeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :google_auth_scope, :string
  end
end
