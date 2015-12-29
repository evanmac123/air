require 'acceptance/acceptance_helper'

feature 'Sees all inactive tiles on a separate page' do
  let(:client_admin) { a_client_admin }
  let(:demo)         { client_admin.demo }

  def click_see_all_inactive_tiles_link
    page.find(".all_inactive").click
  end

  it "should show inactive tiles in the demo" do
    tiles = []
    5.times { |i| tiles << FactoryGirl.create(:tile, :archived, demo: demo, headline: "Tile #{i}") }
    visit client_admin_inactive_tiles_path(as: client_admin)

    tiles.each {|tile| expect_content tile.headline }
  end

  it "should be linked to from the main tiles page" do
    5.times {FactoryGirl.create(:tile, :archived, demo: demo) }
    visit client_admin_tiles_path(as: client_admin)
    click_see_all_inactive_tiles_link
    should_be_on client_admin_inactive_tiles_path
  end

  context "should show 12 tiles per page" do
    it "should show first 12 tiles on first page" do
      tiles = []
      12.times { |i| tiles << FactoryGirl.create(:tile, :archived, demo: demo, headline: "Tile #{i}") }
      visit client_admin_inactive_tiles_path(as: client_admin)

      tiles.each {|tile| expect_content tile.headline }

      tile_13 = FactoryGirl.create(:tile, :archived, demo: demo, headline: "Tile 13")
      page_text.should_not include(tile_13.headline)
    end

    it "should show second 12 tiles on second page" do
      tiles_2 = []
      (1..12).each { |i| tiles_2 << FactoryGirl.create(:tile, :archived, demo: demo, headline: "Tile #{i}") }
      tiles_1 = []
      (13..24).each{ |i| tiles_1 << FactoryGirl.create(:tile, :archived, demo: demo, headline: "Tile #{i}") }
      visit client_admin_inactive_tiles_path(as: client_admin, page: 2)

      tiles_1.each {|tile| page_text.should_not include(tile.headline) }
      tiles_2.each {|tile| expect_content tile.headline }
    end
  end
end
