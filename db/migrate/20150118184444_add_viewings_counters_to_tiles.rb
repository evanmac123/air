class AddViewingsCountersToTiles < ActiveRecord::Migration
  def up
  	add_column :tiles, :unique_viewings_count, :integer, :null => false, :default => 0
  	add_column :tiles, :total_viewings_count, :integer, :null => false, :default => 0

  	TileViewing.counter_culture_fix_counts
  end

  def down
  	remove_column :tiles, :unique_viewings_count
  	remove_column :tiles, :total_viewings_count
  end
end
