class AddImageMetaToTileImages < ActiveRecord::Migration
  def up
    add_column :tile_images, :image_meta, :text
  end

  def down
    remove_column :tile_images, :image_meta
  end
end
