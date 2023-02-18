class CreateHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :histories do |t|
      t.string  :target, :null => false
      t.string  :target_type
      t.integer :target_id
      t.string  :action, :null => false
      t.integer :user_id
      t.text    :note

      t.datetime :created_at, :null => false
    end

    add_index :histories, [:created_at, :target, :target_id]
    add_index :histories, [:user_id, :created_at]
  end
end
