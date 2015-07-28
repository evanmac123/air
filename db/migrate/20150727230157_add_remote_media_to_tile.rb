class AddRemoteMediaToTile < ActiveRecord::Migration
  def change
    add_column :tiles, :remote_media_url, :string
    add_column :tiles, :remote_media_type, :string
  end
end
