require 'acceptance/acceptance_helper'

feature 'User searches for tile', js: true, search: true do

  before do
    organization = FactoryBot.create(:organization)
    demo = FactoryBot.create(:demo, organization: organization)

    _active_tiles = FactoryBot.create_list(:tile, 3, headline: "active-tile", demo: demo, status: Tile::ACTIVE)
    archived_tiles = FactoryBot.create_list(:tile, 3, demo: demo, headline: "archived-tile", status: Tile::ARCHIVE)
    _draft_tiles = FactoryBot.create_list(:tile, 3, demo: demo, headline: "draft-tile", status: Tile::DRAFT)

    Tile.reindex

    user = FactoryBot.create(:user, demo: demo)
    TileCompletion.create(tile: archived_tiles.first, user: user)

    visit root_path(as: user)
    visit root_path(as: user)
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
