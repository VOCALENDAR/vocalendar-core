class CreateExLinkAccesses < ActiveRecord::Migration
  def change
    create_table :ex_link_accesses do |t|
      t.integer :ex_link_id, :null => false
      t.string :ipaddr
      t.string :user_agent
      t.datetime :created_at, :null => false
    end
    add_index :ex_link_accesses, [:ex_link_id, :created_at]
    add_index :ex_link_accesses, [:ipaddr, :created_at]
    add_index :ex_link_accesses, [:user_agent, :created_at]
    add_index :ex_link_accesses, :created_at
  end
end
