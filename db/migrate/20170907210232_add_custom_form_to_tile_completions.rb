class AddCustomFormToTileCompletions < ActiveRecord::Migration
  def change
    add_column :tile_completions, :custom_form, :text
  end
end
