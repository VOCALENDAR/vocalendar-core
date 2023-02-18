class AddGoogleAuthScopeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :google_auth_scope, :string
  end
end
