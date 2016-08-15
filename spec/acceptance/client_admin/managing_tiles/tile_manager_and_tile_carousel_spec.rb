require 'acceptance/acceptance_helper'

feature 'The order of the tiles in the tile mangaer and carousel are in synch', js:true do

  let(:admin){FactoryGirl.create :client_admin}
  let(:demo) {admin.demo}
  let(:tiles) {[]}

  before do
    UserIntro.any_instance.stubs(:displayed_first_tile_hint).returns(true)
    1.upto(4) { |i| tiles << FactoryGirl.create(:tile, demo: demo, headline: "Tile #{i}", created_at: Time.now + i.days) }
    bypass_modal_overlays(admin)
  end

  context "carousel" do
    scenario "archiving one tile" do
      active_tile_headlines_order =  ["Tile 4", "Tile 2", "Tile 1"]

      tiles[2].update_status('archive')

      signin_as(admin, admin.password)
      visit tile_manager_page

      check_carousel_and_viewer(active_tile_headlines_order, Tile.first)
    end

    scenario "when reactivating one tile" do
      active_tile_headlines_order =  ["Tile 3", "Tile 4", "Tile 2", "Tile 1"]

      tiles[2].update_status('archive')
      tiles[2].update_status('active')

      signin_as(admin, admin.password)
      visit tile_manager_page

      check_manager(active_tile_headlines_order)
      check_carousel_and_viewer(active_tile_headlines_order, tiles[2])
   end


   scenario "when reactivation mutiple tiles" do
     active_tile_headlines_order =  ["Tile 4", "Tile 1", "Tile 3", "Tile 2"]

     tiles[3].update_status('archive')
     tiles[0].update_status('archive')
     tiles[0].update_status('active')
     tiles[3].update_status('active')

     signin_as(admin, admin.password)
     visit tile_manager_page

     check_manager(active_tile_headlines_order)
     check_carousel_and_viewer(active_tile_headlines_order, Tile.active.last)
   end
  end

  context 'Tile Mananager' do
   #NOTE really should be a client side using a js framework

    it "displays recently created tiles in reversse creation order" do
      active_tile_headlines_order =  ["Tile 4", "Tile 3", "Tile 2", "Tile 1"]

      signin_as(admin, admin.password)
      visit tile_manager_page
      check_manager(active_tile_headlines_order)
      check_carousel_and_viewer(active_tile_headlines_order, Tile.first)
    end


    scenario "Moves archived tile moves from active to archived section", js:true do
      #FIXME this is a good candidate for pure js test.
      signin_as(admin, admin.password)

      visit tile_manager_page

      selector= "#single-tile-#{tiles[2].id}.tile_thumbnail>.tile-wrapper"

      within "#active_tiles" do
        page.find(selector).hover
        within selector do
          within(".tile_buttons") do
            click_link "Archive"
          end
        end
      end

      within "#archived_tiles" do
        expect(page).to have_content(tiles[2].headline)
      end

      within "#active_tiles" do
        expect(page).to have_no_content(tiles[2].headline)
      end
    end



  end

    def carousel_content
      page.all('.headline .text').collect { |tile| tile.text }
    end

    def viewer_content
      find('#slideshow').find('.tile_image')[:alt]
    end


    def check_manager(active_tile_headlines_order)
      section_tile_headlines('#active').should == active_tile_headlines_order
    end

    def click_next_button
      page.find('#next').click
    end

    # Doesn't matter what tile you click on; just want to get from the Carousel to the Viewer => called with different active tiles
    def check_carousel_and_viewer(active_tile_headlines_order, carousel_tile)
      user_tiles = active_tile_headlines_order

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
end
