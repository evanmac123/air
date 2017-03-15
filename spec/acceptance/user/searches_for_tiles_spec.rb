require 'acceptance/acceptance_helper'

feature 'User searches for tile', js: true do

  before do
    organization = FactoryGirl.create(:organization)
    demo = FactoryGirl.create(:demo, organization: organization)

    _active_tiles = FactoryGirl.create_list(:tile, 3, headline: "active-tile", demo: demo, status: Tile::ACTIVE)
    archived_tiles = FactoryGirl.create_list(:tile, 3, demo: demo, headline: "archived-tile", status: Tile::ARCHIVE)
    _draft_tiles = FactoryGirl.create_list(:tile, 3, demo: demo, headline: "draft-tile", status: Tile::DRAFT)

    Tile.reindex

    user = FactoryGirl.create(:user, demo: demo)
    TileCompletion.create(tile: archived_tiles.first, user: user)

    bypass_modal_overlays(user)
    visit root_path(as: user)
    click_link "Get started!"
  end

  describe "when a user searches for tiles" do
    scenario "all active tiles matching the query should appear" do
      fill_in "query", with: "active"

      page.find("#nav-bar-search-submit").click

      expect(page).to have_selector('.tile_container', count: 3)
    end

    scenario "all acrhived tiles that have completed should appear" do
      fill_in "query", with: "archive"

      page.find("#nav-bar-search-submit").click

      expect(page).to have_selector('.tile_container', count: 1)
    end

    scenario "no draft tiles matching the query should appear" do
      fill_in "query", with: "draft"

      page.find("#nav-bar-search-submit").click

      expect(page).to have_selector('.tile_container', count: 0)
    end
  end
end
