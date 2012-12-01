class RemovedIdentifierFromTiles < ActiveRecord::Migration
  def up
    remove_columns :tiles, :identifier
  end

  def down
    add_column :tiles, :identifier, :string
  end
end
