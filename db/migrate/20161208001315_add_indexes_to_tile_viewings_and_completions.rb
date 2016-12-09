class AddIndexesToTileViewingsAndCompletions < ActiveRecord::Migration
  def change
    add_index :tile_viewings, :created_at
    add_index :tile_viewings, :tile_id

    add_index :tile_completions, :created_at
    add_index :tile_completions, :tile_id
  end
end
