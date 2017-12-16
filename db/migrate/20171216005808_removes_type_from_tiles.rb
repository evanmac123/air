class RemovesTypeFromTiles < ActiveRecord::Migration
  def up
    remove_column :tiles, :type
  end

  def down
    add_column :tiles, :type, :string, default: "MultipleChoiceTile"
  end
end
