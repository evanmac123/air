class AddTileLastPostedAtToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :tile_last_posted_at, :timestamp
  end
end
