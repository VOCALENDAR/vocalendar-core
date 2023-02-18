class SetDefaultsOnExLink < ActiveRecord::Migration[5.1]
  def up
    change_column_default :ex_links, :name, ""
    change_column_default :ex_links, :uri,  ""
    execute("update ex_links set name = '' where name IS NULL")
    execute("update ex_links set uri  = '' where uri  IS NULL")
    change_column_null    :ex_links, :name, false
    change_column_null    :ex_links, :uri,  false
  end

  def down
    change_column_null    :ex_links, :name, true
    change_column_null    :ex_links, :uri,  true
    change_column_default :ex_links, :name, nil
    change_column_default :ex_links, :uri,  nil
  end
end
