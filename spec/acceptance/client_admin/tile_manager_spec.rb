require 'acceptance/acceptance_helper'

feature 'Client admin and the digest email for tiles' do

  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  # -------------------------------------------------

  def tile(tile)
    find(:tile, tile)  # Uses our custom selector (defined in '/support/helpers/tile_helpers.rb')
  end

  def have_archive_link_for(tile)
    have_link 'Archive', href: client_admin_tile_path(tile, update_status: Tile::ARCHIVE)
  end

  def have_activate_link_for(tile)
    have_link 'Activate', href: client_admin_tile_path(tile, update_status: Tile::ACTIVE)
  end

  def have_edit_link_for(tile)
    have_link 'Edit', href: edit_client_admin_tile_path(tile)
  end

  def have_preview_link_for(tile)
    have_link 'Preview', href: client_admin_tile_path(tile)
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
    # NOTES 1: The default 'status' for tiles is 'active'
    #       2: I have no idea why Phil hates kittens so much. Someone should keep an eye on him...
    #
    #       (I don't hate kittens. I love them, especially in soy sauce. --Phil)
    let(:kill)        { create_tile headline: 'Phil Kills Kittens',  start_day: '12/25/2013', end_day: '12/30/2013' }
    let(:knife)       { create_tile headline: 'Phil Knifes Kittens', start_day: '12/25/2013' }
    let(:kannibalize) { create_tile headline: 'Phil Kannibalizes Kittens' }

    let!(:tiles) { [kill, knife, kannibalize] }

    scenario "The tile content is correct for Active tiles" do
      visit tile_manager_page
      active_tab.should have_num_tiles(3)

      within active_tab do
        tiles.each do |tile|
          within tile(tile) do
            page.should contain tile.headline
            page.should have_archive_link_for(tile)
            page.should have_edit_link_for(tile)
            page.should have_preview_link_for(tile)
          end
        end
      end
    end

    scenario "The tile content is correct for Digest tiles" do
      demo.update_attributes tile_digest_email_sent_at: Date.yesterday

      visit tile_manager_page
      digest_tab.should have_num_tiles(3)

      within digest_tab do
        # One check at this level is good enough
        page.should_not contain 'Archive'
        page.should_not contain 'Activate'

        tiles.each do |tile|
          within tile(tile) do
            page.should contain tile.headline
          end
        end
      end
    end

    scenario "The tile content is correct for Archive tiles" do
      tiles.each { |tile| tile.update_attributes status: Tile::ARCHIVE }

      visit tile_manager_page
      archive_tab.should have_num_tiles(3)

      within archive_tab do
        tiles.each do |tile|
          within tile(tile) do
            page.should contain tile.headline
            page.should have_activate_link_for(tile)
          end
        end
      end
    end

    scenario "Tiles that should be archived, are, whenever the page is displayed" do
      tiles.each { |tile| tile.update_attributes end_time: Date.tomorrow }
      visit tile_manager_page

      active_tab.should have_num_tiles(3)
      archive_tab.should have_num_tiles(0)

      tiles.each { |tile| tile.update_attributes end_time: Date.yesterday }
      refresh_tile_manager_page

      active_tab.should have_num_tiles(0)
      archive_tab.should have_num_tiles(3)

      tiles.each { |tile| tile.reload.status.should == Tile::ARCHIVE }
    end

    context 'Archiving and activating tiles' do
      scenario "The 'Archive this tile' links work, including setting the 'archived_at' time" do
        visit tile_manager_page

        active_tab.should  have_num_tiles(3)
        archive_tab.should have_num_tiles(0)

        kill.archived_at.should be_nil

        active_tab.find(:tile, kill).click_link('Archive')
        page.should contain "The #{kill.headline} tile has been archived"

        kill.reload.archived_at.sec.should be_within(1).of(Time.now.sec)
        kill.activated_at.should be_nil

        within(active_tab)  { page.should_not contain kill.headline }
        within(archive_tab) { page.should     contain kill.headline }

        active_tab.should  have_num_tiles(2)
        archive_tab.should have_num_tiles(1)

        # Let's try it one more time to make sure...
        knife.archived_at.should be_nil

        active_tab.find(:tile, knife).click_link('Archive')
        page.should contain "The #{knife.headline} tile has been archived"

        knife.reload.archived_at.sec.should be_within(1).of(Time.now.sec)
        knife.activated_at.should be_nil

        within(active_tab)  { page.should_not contain knife.headline }
        within(archive_tab) { page.should     contain knife.headline }

        active_tab.should  have_num_tiles(1)
        archive_tab.should have_num_tiles(2)
      end

      scenario "The 'Activate this tile' links work, including setting the 'activated_at' time" do
        tiles.each { |tile| tile.update_attributes status: Tile::ARCHIVE }
        visit tile_manager_page

        active_tab.should  have_num_tiles(0)
        archive_tab.should have_num_tiles(3)

        kill.activated_at.should be_nil

        archive_tab.find(:tile, kill).click_link('Activate')
        page.should contain "The #{kill.headline} tile has been activated"

        kill.reload.activated_at.sec.should be_within(1).of(Time.now.sec)
        kill.archived_at.should be_nil

        within(archive_tab) { page.should_not contain kill.headline }
        within(active_tab)  { page.should     contain kill.headline }

        active_tab.should  have_num_tiles(1)
        archive_tab.should have_num_tiles(2)

        # Let's try it one more time to make sure...
        knife.activated_at.should be_nil

        archive_tab.find(:tile, knife).click_link('Activate')
        page.should contain "The #{knife.headline} tile has been activated"

        knife.reload.activated_at.sec.should be_within(1).of(Time.now.sec)
        knife.archived_at.should be_nil

        within(archive_tab) { page.should_not contain knife.headline }
        within(active_tab)  { page.should     contain knife.headline }

        active_tab.should  have_num_tiles(2)
        archive_tab.should have_num_tiles(1)
      end
    end
  end
end
