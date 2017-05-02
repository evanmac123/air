class AddCopyCountsToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :copy_count, :integer, default: 0
  end
end
