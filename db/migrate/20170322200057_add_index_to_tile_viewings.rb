class AddIndexToTileViewings < ActiveRecord::Migration
  def up
    add_index :tile_viewings, [:tile_id, :user_type]
    add_index :tile_viewings, :user_id
    remove_index :tile_viewings, :tile_id

    remove_index :tile_completions, :tile_id
    add_index :tile_completions, [:tile_id, :user_type]
    add_index :tile_completions, [:tile_id, :user_id, :user_type]
    remove_index :tile_completions, name: 'index_task_suggestions_on_task_id'
  end

  def down
    remove_index :tile_viewings, [:tile_id, :user_type]
    remove_index :tile_viewings, :user_id
    add_index :tile_viewings, :tile_id

    add_index :tile_completions, :tile_id
    remove_index :tile_completions, [:tile_id, :user_type]
    remove_index :tile_completions, [:tile_id, :user_id, :user_type]
  end
end
