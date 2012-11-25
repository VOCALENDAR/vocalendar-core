class ChangeTargetFieldDefaultOnTagRelations < ActiveRecord::Migration
  def up
    remove_index :event_tag_relations, :event_id
    change_column_default :event_tag_relations, :target_field, ""
    execute("update event_tag_relations set target_field = '' where target_field IS NULL")
    change_column_null    :event_tag_relations, :target_field, false
    add_index    :event_tag_relations, [:event_id, :target_field]
  end

  def down
    remove_index :event_tag_relations, [:event_id, :target_field]
    change_column_null    :event_tag_relations, :target_field, true
    change_column_default :event_tag_relations, :target_field, nil
    execute("update event_tag_relations set target_field = NULL where target_field = ''")
    add_index    :event_tag_relations, :event_id
  end
end
