class AddSlugToTileFeature < ActiveRecord::Migration
  def change
    add_column :tile_features, :slug, :string
  end
end
