class ChangeNameToTitleOnExLink < ActiveRecord::Migration[5.1]
  def change
    rename_column :ex_links, :name, :title
  end
end
