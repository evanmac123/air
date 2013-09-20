require 'acceptance/acceptance_helper'

feature 'The order of the tiles in the Tile Manager and the Tile Carousel are in synch' do
  # Both of these helpers grab all of the tiles, in order, whether visible or not

  def carousel_content
    page.all('.headline .text').collect { |tile| tile.text }
  end

  def viewer_content
    find('#slideshow').all('.tile_image').collect { |tile| tile[:alt] }
  end

  #------------------------------------------------------------------------------------

  def check_manager(manager_tiles)
    table_content_without_activation_dates('#active table').should == manager_tiles
  end

  # Doesn't matter what tile you click on; just want to get from the Carousel to the Viewer => called with different active tiles
  def check_carousel_and_viewer(manager_tiles, carousel_tile)
    user_tiles = manager_tiles.flatten

    visit activity_path
    carousel_content.should == user_tiles

    click_carousel_tile(carousel_tile)
    viewer_content.should == user_tiles
  end

  #------------------------------------------------------------------------------------

  scenario 'Bounce back and forth between the Manager and the Carousel' do
    admin = FactoryGirl.create :client_admin
    demo = admin.demo

    tiles = []
    5.times { |i| tiles << FactoryGirl.create(:tile, demo: demo, headline: "Tile #{i}", created_at: Time.now + i.days) }

    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)

    # -----------------------------------------------------------------------------

    visit tile_manager_page
    manager_tiles =  [ ["Tile 4", "Tile 3", "Tile 2"], ["Tile 1", "Tile 0"] ]

    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.first)

    # -----------------------------------------------------------------------------
    # Change the tile order in the Manager => should see the corresponding change in the Carousel and Viewer
    visit tile_manager_page
    active_tab.find(:tile, tiles[3]).click_link('Archive')
    manager_tiles =  [ ["Tile 4", "Tile 2", "Tile 1"], ["Tile 0"] ]

    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.last)

    # -----------------------------------------------------------------------------
    # Re-activate the archived tile => should move to the head of the list
    visit tile_manager_page
    archive_tab.find(:tile, tiles[3]).click_link('Activate')
    manager_tiles =  [ ["Tile 3", "Tile 4", "Tile 2"], ["Tile 1", "Tile 0"] ]

    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.last)

    # -----------------------------------------------------------------------------
    # Change the tile order in the Manager => should see the corresponding change in the Carousel and Viewer
    visit tile_manager_page
    active_tab.find(:tile, tiles[4]).click_link('Archive')
    active_tab.find(:tile, tiles[1]).click_link('Archive')
    manager_tiles =  [ ["Tile 3", "Tile 2", "Tile 0"] ]

    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.active.first)

    #-------------------------------------------------------------------------------
    # Re-activate the archived tile => should move to the head of the list
    visit tile_manager_page
    archive_tab.find(:tile, tiles[1]).click_link('Activate')
    manager_tiles =  [ ["Tile 1", "Tile 3", "Tile 2"], ["Tile 0"] ]

    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.active.last)

    #-------------------------------------------------------------------------------
    # Re-activate the archived tile => should move to the head of the list
    visit tile_manager_page
    archive_tab.find(:tile, tiles[4]).click_link('Activate')
    manager_tiles =  [ ["Tile 4", "Tile 1", "Tile 3"], ["Tile 2", "Tile 0"] ]

    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.active.last)
  end
end
