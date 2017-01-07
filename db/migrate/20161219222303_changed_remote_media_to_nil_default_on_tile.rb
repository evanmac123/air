class ChangedRemoteMediaToNilDefaultOnTile < ActiveRecord::Migration
  def change
    change_column :tiles, :remote_media_url, :string, default: nil
  end

end
