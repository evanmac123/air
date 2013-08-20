class AddSampleTileCompletedFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :sample_tile_completed, :boolean
  end
end
