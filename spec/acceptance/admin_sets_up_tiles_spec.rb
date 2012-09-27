require 'acceptance/acceptance_helper'

feature 'Admin sets up tiles' do

  before(:each) do
    @demo = FactoryGirl.create(:demo)

    signin_as_admin
    visit new_admin_demo_tile_path(@demo)
  end

  scenario 'and uploads an image' do
    fill_in "Identifier", :with => 'tile with image'

    attach_file "tile[image]", tile_fixture_path('cov1.jpg')
    click_button "Create Tile"

    expect_content 'tile with image'
    expect_content 'cov1.jpg'

    expect_link 'cov1.jpg', Tile.last.image.url
  end

  scenario "and uploads a thumbnail" do
    fill_in "Identifier", :with => 'tile with image'

    attach_file "tile[thumbnail]", tile_fixture_path('cov1_thumbnail.jpg')
    click_button "Create Tile"

    expect_content 'tile with image'
    expect_content 'cov1_thumbnail.jpg'

    expect_link 'cov1_thumbnail.jpg', Tile.last.thumbnail.url
  end
end
