require 'acceptance/acceptance_helper'

feature "Client admin opens tile stats" do
  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :client_admin, demo: demo }

  def tile_cell(tile)
    "[data-tile_id='#{tile.id}']"
  end

  def open_stats(tile)
    visit client_admin_tiles_path(as: client_admin)
    within tile_cell(tile) do
      page.find(".tile_stats").click
    end
  end

  context "tile with empty stats" do
    before do
      @tile = FactoryGirl.create :tile, status: Tile::ACTIVE, demo: demo
      open_stats(@tile)
    end

    it "should show tile stats modal" do
      
    end
  end
end
