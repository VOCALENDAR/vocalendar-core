class ChangeNameToTitleOnExLink < ActiveRecord::Migration
  def change
    rename_column :ex_links, :name, :title
  end
end
