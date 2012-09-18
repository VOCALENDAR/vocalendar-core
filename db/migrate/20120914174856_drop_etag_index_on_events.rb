class DropEtagIndexOnEvents < ActiveRecord::Migration
  def change
    remove_index :events, :etag
  end
end
