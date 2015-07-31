class AddRemoteMediaUrlToTileImage < ActiveRecord::Migration
  def change
    add_column :tile_images, :remote_media_url, :string
  end
end
