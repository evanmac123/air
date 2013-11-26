require 'acceptance/acceptance_helper'

feature 'Sees all inactive tiles on a separate page' do
  let(:client_admin) { a_client_admin }
  let(:demo)         { client_admin.demo }

  def click_see_all_inactive_tiles_link
    click_link "Show all"
  end

  it "should show all inactive tiles in the demo" do
    tiles = []
    5.times { |i| tiles << FactoryGirl.create(:tile, :archived, demo: demo, headline: "Tile #{i}") }
    visit client_admin_inactive_tiles_path(as: client_admin)

    tiles.each {|tile| expect_content tile.headline }
  end

  it "should be linked to from the main tiles page" do
    visit client_admin_tiles_path(as: client_admin)
    click_see_all_inactive_tiles_link
    should_be_on client_admin_inactive_tiles_path
  end

   it "has a placeholder that you can click on to create a new tile" do
     visit client_admin_inactive_tiles_path(as: client_admin)
     click_new_tile_placeholder
     should_be_on new_client_admin_tile_path
   end

end
