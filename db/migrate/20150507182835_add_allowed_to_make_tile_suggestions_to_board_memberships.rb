class AddAllowedToMakeTileSuggestionsToBoardMemberships < ActiveRecord::Migration
  def change
  	add_column :board_memberships, :allowed_to_make_tile_suggestions, :boolean, default: false, null: false
  end
end