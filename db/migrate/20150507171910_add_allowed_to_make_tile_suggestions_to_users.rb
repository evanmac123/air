class AddAllowedToMakeTileSuggestionsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :allowed_to_make_tile_suggestions, :boolean, default: false, null: false
  end
end
