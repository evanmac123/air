class AddIndexingToTileCompletions < ActiveRecord::Migration
  def change
    add_index :tile_completions, [:user_id, :user_type]
  end
end
