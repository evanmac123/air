require 'acceptance/acceptance_helper'

feature 'The order of the tiles in the Tile Manager and the Tile Carousel are in synch' do
  # Both of these helpers grab all of the tiles, in order, whether visible or not

  def carousel_content
    page.all('.headline .text').collect { |tile| tile.text }
  end

  def viewer_content
    find('#slideshow').find('.tile_image')[:alt]
  end

  #------------------------------------------------------------------------------------

  def check_manager(manager_tiles)
    section_tile_headlines('#active').should == manager_tiles
  end

  def click_next_button
    page.find('#next').click
  end

  # Doesn't matter what tile you click on; just want to get from the Carousel to the Viewer => called with different active tiles
  def check_carousel_and_viewer(manager_tiles, carousel_tile)
    user_tiles = manager_tiles.flatten

    visit activity_path
    carousel_content.should == user_tiles

    click_carousel_tile(carousel_tile)
    click_next_button

    user_tiles.each do |user_tile|
      next if user_tile == carousel_tile.headline
      viewer_content.should == user_tile
      click_next_button
    end
  end

  #------------------------------------------------------------------------------------

  scenario 'Bounce back and forth between the Manager and the Carousel', js: true do#, driver: :selenium do
    admin = FactoryGirl.create :client_admin
    demo = admin.demo

    tiles = []
    1.upto(4) { |i| tiles << FactoryGirl.create(:tile, demo: demo, headline: "Tile #{i}", created_at: Time.now + i.days) }

    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)

    # -----------------------------------------------------------------------------

    visit tile_manager_page
    manager_tiles =  ["Tile 4", "Tile 3", "Tile 2", "Tile 1"]

    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.first)

    # -----------------------------------------------------------------------------
    # Change the tile order in the Manager => should see the corresponding change in the Carousel and Viewer
    #
    # We now tweak the attributes directly rather than going through the manager
    # page, since we can't easily hover over and click "Archive" via Poltergiest

    Tile.find_by_headline('Tile 3').update_status('archive')
    visit tile_manager_page

    manager_tiles =  ["Tile 4", "Tile 2", "Tile 1"]
    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.first)

    # -----------------------------------------------------------------------------
    # Re-activate the archived tile => should move to the head of the list
    # See previous note about why we update_attributes for this
    Tile.find_by_headline('Tile 3').update_status('active')

    visit tile_manager_page
    manager_tiles =  ["Tile 3", "Tile 4", "Tile 2", "Tile 1"]

    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.find_by_headline("Tile 3"))

    # -----------------------------------------------------------------------------
    # Change the tile order in the Manager => should see the corresponding change in the Carousel and Viewer
    Tile.find_by_headline('Tile 4').update_status('archive')
    Tile.find_by_headline('Tile 1').update_status('archive')
    visit tile_manager_page
    manager_tiles =  ["Tile 3", "Tile 2"]

    check_manager(manager_tiles)
    check_carousel_and_viewer(["Tile 3", "Tile 2"], Tile.find_by_headline("Tile 3"))

    #-------------------------------------------------------------------------------
    # Re-activate the archived tile => should move to the head of the list
    Tile.find_by_headline('Tile 1').update_status('active')
    visit tile_manager_page
    manager_tiles =  ["Tile 1", "Tile 3", "Tile 2"]

    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.active.last)

    #-------------------------------------------------------------------------------
    # Re-activate the archived tile => should move to the head of the list
    Tile.find_by_headline('Tile 4').update_status('active')
    visit tile_manager_page
    manager_tiles =  ["Tile 4", "Tile 1", "Tile 3", "Tile 2"]

    check_manager(manager_tiles)
    check_carousel_and_viewer(manager_tiles, Tile.active.last)
  end
end
