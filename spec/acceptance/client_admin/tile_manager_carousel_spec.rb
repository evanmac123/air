require 'acceptance/acceptance_helper'

feature 'The order of the tiles in the Tile Manager and the Tile Carousel are in synch' do
  # Both of these helpers grab all of the tiles, in order, whether visible or not

  def carousel_content
    find('#carousel_wrapper').all('.headline .text').collect { |tile| tile.text }
  end

  def viewer_content
    find('#slideshow').all('.tile_image').collect { |tile| tile[:alt] }
  end

  #------------------------------------------------------------------------------------

  scenario 'Bounce back and forth between the Manager and the Carousel' do
    admin = FactoryGirl.create :client_admin
    demo = admin.demo

    tiles = []
    5.times { |i| tiles << FactoryGirl.create(:tile, demo: demo, headline: "Tile #{i}", created_at: Time.now + i.days) }

    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)

    expected_admin_tiles =  [ ["Tile 4", "Tile 3", "Tile 2"], ["Tile 1", "Tile 0"] ]
    expected_user_tiles = expected_admin_tiles.flatten

    # -----------------------------------------------------------------------------

    visit tile_manager_page
    table_content_without_activation_dates('#active table').should == expected_admin_tiles

    visit activity_path
    carousel_content.should == expected_user_tiles

    click_carousel_tile(Tile.first)  # Doesn't matter what tile you click on; just want to get from the Carousel to the Viewer
    viewer_content.should == expected_user_tiles

    # -----------------------------------------------------------------------------
    # Change the tile order in the Manager => should see the corresponding change in the Carousel and Viewer
    visit tile_manager_page
    active_tab.find(:tile, tiles[3]).click_link('Archive')

    expected_admin_tiles =  [ ["Tile 4", "Tile 2", "Tile 1"], ["Tile 0"] ]
    expected_user_tiles = expected_admin_tiles.flatten

    table_content_without_activation_dates('#active table').should == expected_admin_tiles

    visit activity_path
    carousel_content.should == expected_user_tiles

    click_carousel_tile(Tile.last)
    viewer_content.should == expected_user_tiles

    # -----------------------------------------------------------------------------
    # Re-activate the archived tile => should move to the head of the list
    visit tile_manager_page
    archive_tab.find(:tile, tiles[3]).click_link('Activate')

    expected_admin_tiles =  [ ["Tile 3", "Tile 4", "Tile 2"], ["Tile 1", "Tile 0"] ]
    expected_user_tiles = expected_admin_tiles.flatten

    table_content_without_activation_dates('#active table').should == expected_admin_tiles

    visit activity_path
    carousel_content.should == expected_user_tiles

    click_carousel_tile(Tile.last)
    viewer_content.should == expected_user_tiles

    # -----------------------------------------------------------------------------
    # Change the tile order in the Manager => should see the corresponding change in the Carousel and Viewer
    visit tile_manager_page
    active_tab.find(:tile, tiles[4]).click_link('Archive')
    active_tab.find(:tile, tiles[1]).click_link('Archive')

    expected_admin_tiles =  [ ["Tile 3", "Tile 2", "Tile 0"] ]
    expected_user_tiles = expected_admin_tiles.flatten

    table_content_without_activation_dates('#active table').should == expected_admin_tiles

    visit activity_path
    carousel_content.should == expected_user_tiles

    click_carousel_tile(Tile.active.first)
    viewer_content.should == expected_user_tiles

    #-------------------------------------------------------------------------------
    # Re-activate the archived tile => should move to the head of the list
    visit tile_manager_page
    archive_tab.find(:tile, tiles[1]).click_link('Activate')

    expected_admin_tiles =  [ ["Tile 1", "Tile 3", "Tile 2"], ["Tile 0"] ]
    expected_user_tiles = expected_admin_tiles.flatten

    table_content_without_activation_dates('#active table').should == expected_admin_tiles

    visit activity_path
    carousel_content.should == expected_user_tiles

    click_carousel_tile(Tile.active.last)
    viewer_content.should == expected_user_tiles

    #-------------------------------------------------------------------------------
    # Re-activate the archived tile => should move to the head of the list
    visit tile_manager_page
    archive_tab.find(:tile, tiles[4]).click_link('Activate')

    expected_admin_tiles =  [ ["Tile 4", "Tile 1", "Tile 3"], ["Tile 2", "Tile 0"] ]
    expected_user_tiles = expected_admin_tiles.flatten

    table_content_without_activation_dates('#active table').should == expected_admin_tiles

    visit activity_path
    carousel_content.should == expected_user_tiles

    click_carousel_tile(Tile.last)
    viewer_content.should == expected_user_tiles
  end
end
