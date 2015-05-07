class AddEveryoneCanMakeTileSuggestionsToDemos < ActiveRecord::Migration
  def change
  	add_column :demos, :everyone_can_make_tile_suggestions, :boolean, default: false, null: false
  end
end
