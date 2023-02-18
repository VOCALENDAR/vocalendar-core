class FixTypeOfTimeColsOfOmniAuthOnUsers < ActiveRecord::Migration[5.1]
  def up
    change_column :users, :google_token_expires_at, :datetime
    change_column :users, :google_token_issued_at, :datetime
    add_column :users, :twitter_token_issued_at, :datetime
  end

  def down
    change_column :users, :google_token_expires_at, :string
    change_column :users, :google_token_issued_at, :string
    remove_column :users, :twitter_token_issued_at
  end
end
