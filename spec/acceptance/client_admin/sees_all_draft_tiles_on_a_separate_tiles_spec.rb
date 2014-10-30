require 'acceptance/acceptance_helper'

feature 'Sees all draft tiles on a separate page' do
  let(:client_admin) { a_client_admin }
  let(:demo)         { client_admin.demo }

  def click_see_all_draft_tiles_link
    page.find(".all_draft").click
  end

  it "should show all draft tiles in the demo" do
    tiles = []
    5.times { |i| tiles << FactoryGirl.create(:tile, :draft, demo: demo, headline: "Tile #{i}") }
    visit client_admin_draft_tiles_path(as: client_admin)

    tiles.each {|tile| expect_content tile.headline }
  end

  it "should be linked to from the main tiles page" do
    visit client_admin_tiles_path(as: client_admin)
    click_see_all_draft_tiles_link
    should_be_on client_admin_draft_tiles_path
  end

  it "has a placeholder that you can click on to create a new tile" do
    visit client_admin_draft_tiles_path(as: client_admin)
    sleep 50
    click_new_tile_placeholder
    should_be_on new_client_admin_tile_path
  end

  context "should show 12 tiles per page" do
    it "should show first 11 tiles on first page(one placeholder for create)" do
      tiles = []
      11.times { |i| tiles << FactoryGirl.create(:tile, :draft, demo: demo, headline: "Tile #{i}") }
      visit client_admin_draft_tiles_path(as: client_admin)

      tiles.each {|tile| expect_content tile.headline }

      tile_12 = FactoryGirl.create(:tile, :draft, demo: demo, headline: "Tile 12")
      page_text.should_not include(tile_12.headline)
    end

    it "should show second 12 tiles on second page" do
      tiles_2 = []
      (1..12).each { |i| tiles_2 << FactoryGirl.create(:tile, :draft, demo: demo, headline: "Tile #{i}") }
      tiles_1 = []
      (13..23).each{ |i| tiles_1 << FactoryGirl.create(:tile, :draft, demo: demo, headline: "Tile #{i}") }
      visit client_admin_draft_tiles_path(as: client_admin, page: 2)

      tiles_1.each {|tile| page_text.should_not include(tile.headline) }
      tiles_2.each {|tile| expect_content tile.headline }
    end
  end
end
