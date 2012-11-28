class AddUrisToEvent < ActiveRecord::Migration
  def change
    add_column :events, :primary_link_id, :integer
    add_column :tags,   :primary_link_id, :integer
    add_index  :events, :primary_link_id
    add_index  :tags,   :primary_link_id
  end
end
