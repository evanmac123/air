class AddedHeadlineToTile < ActiveRecord::Migration
  def up
    add_column :tiles, :headline, :string, :null => false, :default => ""
  end

  def down
    remove_columns :tiles, :headline
  end
end
