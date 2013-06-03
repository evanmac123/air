require 'acceptance/acceptance_helper'

# After this initial creation, note that 'admin' is used instead of 'client-admin'
feature 'Client admin and the digest email for tiles', js: true do

  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  # -------------------------------------------------

  context 'No tiles exist for any of the types' do

    before(:each) { visit tile_manager_page }

    scenario 'Correct message is displayed when there are no Active tiles' do
      select_tab 'Active'

      active_tab.should contain 'There are no active tiles'
      active_tab.should have_num_tiles(0)
    end

    scenario 'Correct message is displayed when there are no Archive tiles' do
      select_tab 'Archive'

      archive_tab.should contain 'There are no archived tiles'
      archive_tab.should have_num_tiles(0)
    end

    # Note: The no-tiles digest message is more involved than that of the other tiles.
    #       More comprehensive tests for the various flavors of this message exist in the 'tile_digest_notification_spec'
    scenario 'Correct message is displayed when there are no Digest tiles' do
      select_tab 'Digest'

      digest_tab.should contain 'No digest email is scheduled to be sent'
      digest_tab.should have_num_tiles(0)
    end
  end

  context 'Tiles exist for each of the types' do

    scenario "The tile content is correct for Active tiles" do
      create_tile headline: 'Phil Kills Kittens',  start_day: '12/25/2013', end_day: '12/30/2013'
      create_tile headline: 'Phil Knifes Kittens', start_day: '12/25/2013'
      create_tile headline: 'Phil Kannibalizes Kittens'    # Yes, that's Kannablize with a 'K'

      visit tile_manager_page
      select_tab 'Active'

      active_tab.should contain 'Phil Kills Kittens'
      active_tab.should contain 'December 25, 2013 - December 30, 2013'
      active_tab.should contain 'Archive this tile'
      active_tab.should have_num_tiles(3)
    end
  end
end