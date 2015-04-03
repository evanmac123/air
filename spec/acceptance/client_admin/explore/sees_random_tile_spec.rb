require 'acceptance/acceptance_helper'

include RngHelper

feature 'Sees random tile' do
  scenario "when they click on the link for one in the explore page tile preview" do
    tile_indices = [1, 1, 0, 2, 1, 0]
    tiles = FactoryGirl.create_list(:tile, 3, :public).sort_by(&:id)
    rig_rng(RandomPublicTileChooser, 3, tile_indices)

    visit explore_tile_preview_path(Tile.first, as: a_client_admin)

    tile_indices.each do |tile_index|
      click_link "Random Tile"
      should_be_on explore_tile_preview_path(tiles[tile_index])
    end
  end
end
