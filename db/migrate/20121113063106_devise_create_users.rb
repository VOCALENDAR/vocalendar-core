class DeviseCreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table(:users) do |t|
      t.string :name, :null => false, :default => ""
      t.string :email

      t.string  :google_account
      t.string  :google_auth_token
      t.string  :google_refresh_token
      t.string  :google_token_expires_at
      t.string  :google_token_issued_at
      t.boolean :google_auth_valid, :null => false, :default => false

      t.string  :twitter_uid
      t.string  :twitter_nick
      t.string  :twitter_name
      t.string  :twitter_token
      t.string  :twitter_secret
      t.boolean :twitter_auth_valid, :null => false, :default => false

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.string   :role

      t.timestamps
    end

    add_index :users, :email,          :unique => true
    add_index :users, :google_account, :unique => true
    add_index :users, :twitter_uid,    :unique => true
    add_index :users, :role
  end
end
