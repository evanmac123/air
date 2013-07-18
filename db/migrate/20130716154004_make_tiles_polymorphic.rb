class MakeTilesPolymorphic < ActiveRecord::Migration
  def up
    add_column :tiles, :type, :string
    execute "UPDATE tiles SET type='OldSchoolTile'      WHERE tiles.question IS NULL AND tiles.multiple_choice_answers IS NULL"
    execute "UPDATE tiles SET type='KeywordTile'        WHERE tiles.question IS NOT NULL AND tiles.multiple_choice_answers IS NULL"
    execute "UPDATE tiles SET type='MultipleChoiceTile' WHERE tiles.question IS NOT NULL AND tiles.multiple_choice_answers IS NOT NULL"
  end

  def down
    remove_column :tiles, :type
  end
end
