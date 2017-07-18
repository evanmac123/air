class AddFreeFormResponseToTileCompletions < ActiveRecord::Migration
  def change
    add_column :tile_completions, :free_form_response, :text
  end
end
