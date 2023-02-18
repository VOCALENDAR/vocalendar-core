class AddGEidToEvent < ActiveRecord::Migration[5.1]
  def up
    add_column :events, :g_eid, :string
    Event.where("g_html_link != ''").each do |e|
      e.g_html_link =~ /eid=([^;&]+)/ or next
      e.update_attribute :g_eid, $1
    end
    add_index  :events, :g_eid
  end
  def down
    remove_column :events, :g_eid
    remove_index  :events, :g_eid
  end
end
