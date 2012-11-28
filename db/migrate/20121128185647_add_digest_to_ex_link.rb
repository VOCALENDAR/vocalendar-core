class AddDigestToExLink < ActiveRecord::Migration
  def change
    add_column :ex_links, :digest, :string, null: false, default: ""
    add_index  :ex_links, :digest, unique: true
  end
end
