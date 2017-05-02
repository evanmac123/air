class ChangeTileRemoteMediaUrlToText < ActiveRecord::Migration
  def up
    change_column :tiles, :remote_media_url, :text
  end
end
