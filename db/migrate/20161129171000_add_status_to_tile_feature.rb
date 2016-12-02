class AddStatusToTileFeature < ActiveRecord::Migration
  def change
    add_column :tile_features, :active, :boolean
  end
end
