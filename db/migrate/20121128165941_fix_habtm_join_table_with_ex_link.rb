class FixHabtmJoinTableWithExLink < ActiveRecord::Migration[5.1]
  def change
    rename_table :tags_ex_links, :ex_links_tags
  end
end
