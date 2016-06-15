class AddEmbedVideoToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :embed_video, :text, :default => "", :null => false
  end
end
