class AddImageMetaToTileImages < ActiveRecord::Migration
  def up
    add_column :tile_images, :image_meta, :text
    TileImage.all.each do |ti|
      ti.image.reprocess!
    end
  end

  def down
    remove_column :tile_images, :image_meta
  end
end
