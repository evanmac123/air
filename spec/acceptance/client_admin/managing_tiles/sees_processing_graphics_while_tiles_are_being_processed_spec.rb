require 'acceptance/acceptance_helper'

feature 'Sees processing graphics while tiles are being processed' do

  before do
    @admin = FactoryGirl.create(:client_admin)
  end

  it 'shows the processing graphic, until the real one is ready', js: true do
    visit new_client_admin_tile_path(as: @admin)
    create_good_tile
    page.find('.tile_image')['src'].should include('cov1.png')
  end

  it 'shows the processing after updating a tile, until the real one is ready', js: true do
    visit new_client_admin_tile_path(as: @admin)
    create_good_tile

    tile = Tile.last
    visit edit_client_admin_tile_path(tile)

    page.find('.tile_image')['src'].should include('cov1.png')
    fake_upload_image 'cov2.png'
    click_button "Update tile"
    page.find('.tile_image')['src'].should include('cov2.png')
  end

  it 'shows the processing thumbnail, until the real one is ready', js: true do
    2.times do
        visit new_client_admin_tile_path(as: @admin)
        create_good_tile
    end
    visit client_admin_tiles_path
    draft_tiles = page.all(".draft")
    draft_tiles.should have(2).tiles

    draft_tiles.each {|draft_tile| draft_tile.find('img')['src'].should include("cov1.png")}
  end

end
