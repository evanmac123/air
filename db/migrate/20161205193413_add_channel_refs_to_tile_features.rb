class AddChannelRefsToTileFeatures < ActiveRecord::Migration
  def change
    add_column :tile_features, :channel_id, :integer
    add_index  :tile_features, :channel_id
  end
end
