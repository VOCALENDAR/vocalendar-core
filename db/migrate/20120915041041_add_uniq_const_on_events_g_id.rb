class AddUniqConstOnEventsGId < ActiveRecord::Migration[5.1]
  def up
    remove_index :events, :g_id
    add_index :events, :g_id, :unique => true
  end

  def down
    remove_index :events, :g_id
    add_index :eventes, :g_id
  end
end
