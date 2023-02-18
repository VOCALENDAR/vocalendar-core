class DropEtagIndexOnEvents < ActiveRecord::Migration[5.1]
  def change
    remove_index :events, :etag
  end
end
