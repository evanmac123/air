class AddColumnNotShowInTileProgressToTileCompletions < ActiveRecord::Migration
  def change
    add_column :tile_completions, :not_show_in_tile_progress, :boolean, default: false
  end
end
