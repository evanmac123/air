class AddTileCreationSourceEnumToTiles < ActiveRecord::Migration
  def self.up
    add_column :tiles, :creation_source_cd, :integer, default: 0
  end

  def self.down
    remove_column :tiles, :creation_source_cd
  end
end
