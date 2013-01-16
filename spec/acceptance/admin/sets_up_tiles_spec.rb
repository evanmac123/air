require 'acceptance/acceptance_helper'

feature 'Admin sets up tiles' do

  before(:each) do
    @demo = FactoryGirl.create(:demo)

    visit new_admin_demo_tile_path(@demo, as: an_admin)
    fill_in "Headline", :with => 'bad ASS'
    attach_file "tile[image]", tile_fixture_path('cov1.jpg')
    attach_file "tile[thumbnail]", tile_fixture_path('cov1_thumbnail.jpg')
  end

  scenario 'and uploads an image' do
    click_button "Create Tile"

    expect_content 'cov1.jpg'
    expect_content 'cov1_thumbnail.jpg'

    expect_link 'cov1.jpg', Tile.last.image.url
    expect_link 'cov1_thumbnail.jpg', Tile.last.thumbnail.url
    Tile.last.image.width.should == 620
  end

  scenario "and fills in a link address" do
    fill_in "Address to link to (optional)", :with => "http://www.google.com"
    click_button "Create Tile"

    visit admin_demo_tiles_path(@demo, as: an_admin)
    expect_link "http://www.google.com", "http://www.google.com"
  end
end
