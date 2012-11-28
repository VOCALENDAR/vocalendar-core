class FixHabtmJoinTableWithExLink < ActiveRecord::Migration
  def change
    rename_table :tags_ex_links, :ex_links_tags
  end
end
