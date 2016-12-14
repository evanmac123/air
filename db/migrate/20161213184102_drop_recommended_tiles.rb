class DropRecommendedTiles < ActiveRecord::Migration
  def up
    drop_table :recommended_tiles
  end

  def down
  end
end
