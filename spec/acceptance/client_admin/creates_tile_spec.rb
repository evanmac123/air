require 'acceptance/acceptance_helper'

feature 'Creates tile' do
  let (:client_admin) { FactoryGirl.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  before do
    visit new_client_admin_tile_path(as: client_admin)
  end

  scenario 'by uploading an image' do
    demo.tiles.should be_empty
    attach_file "tile[image]", tile_fixture_path('cov1.jpg')
    fill_in "Headline", with: "Ten pounds of cheese"
    click_button "Create Tile"

    demo.tiles.reload.should have(1).tile
    new_tile = Tile.last
    new_tile.image_file_name.should == 'cov1.jpg'
    new_tile.thumbnail_file_name.should == 'cov1.jpg'
    new_tile.headline.should == "Ten pounds of cheese"
    
    expect_content "OK, you've created a new tile."
  end

  scenario "with incomplete data should give a gentle rebuff" do
    click_button "Create Tile"

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, please attach an image."
  end
end
