class AddPointsToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :points, :integer
  end
end
