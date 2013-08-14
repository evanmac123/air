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
      select_tab 'Digest email'

      digest_tab.should contain 'No digest email is scheduled to be sent'
      digest_tab.should have_num_tiles(0)
    end
  end

  context 'Tiles exist for each of the types' do
    # NOTES 1: The default 'status' for tiles is 'active'
    #       2: I have no idea why Phil hates kittens so much. Someone should keep an eye on him...
    #
    #       (I don't hate kittens. I love them, especially in soy sauce. --Phil)
    let(:kill)        { create_tile headline: 'Phil Kills Kittens'  }
    let(:knife)       { create_tile headline: 'Phil Knifes Kittens' }
    let(:kannibalize) { create_tile headline: 'Phil Kannibalizes Kittens' }

    let!(:tiles) { [kill, knife, kannibalize] }

    scenario "The tile content is correct for Active tiles" do
      tiles.each { |tile| tile.update_attributes status: Tile::ACTIVE }

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

      # Note that unlike the 'Active' and 'Archive' tile tests, you need to specify the 'activated_at'
      # time because that's how tiles do (or do not) make it into the 'Digest' tab
      tiles.each { |tile| tile.update_attributes status: Tile::ACTIVE, activated_at: Time.now }

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

    context 'Archiving and activating tiles' do
      scenario "The 'Archive this tile' links work, including setting the 'archived_at' time" do
        tiles.each { |tile| tile.update_attributes status: Tile::ACTIVE }
        visit tile_manager_page

        active_tab.should  have_num_tiles(3)
        archive_tab.should have_num_tiles(0)

        kill.archived_at.should be_nil

        active_tab.find(:tile, kill).click_link('Archive')
        page.should contain "The #{kill.headline} tile has been archived"

        kill.reload.archived_at.sec.should be_within(1).of(Time.now.sec)

        within(active_tab)  { page.should_not contain kill.headline }
        within(archive_tab) { page.should     contain kill.headline }

        active_tab.should  have_num_tiles(2)
        archive_tab.should have_num_tiles(1)

        # Let's try it one more time to make sure...
        knife.archived_at.should be_nil

        active_tab.find(:tile, knife).click_link('Archive')
        page.should contain "The #{knife.headline} tile has been archived"

        knife.reload.archived_at.sec.should be_within(1).of(Time.now.sec)

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

        archive_tab.find(:tile, kill).click_link('Activate')
        page.should contain "The #{kill.headline} tile has been activated"

        kill.reload.activated_at.sec.should be_within(1).of(Time.now.sec)

        within(archive_tab) { page.should_not contain kill.headline }
        within(active_tab)  { page.should     contain kill.headline }

        active_tab.should  have_num_tiles(1)
        archive_tab.should have_num_tiles(2)

        # Let's try it one more time to make sure...

        archive_tab.find(:tile, knife).click_link('Activate')
        page.should contain "The #{knife.headline} tile has been activated"

        knife.reload.activated_at.sec.should be_within(1).of(Time.now.sec)

        within(archive_tab) { page.should_not contain knife.headline }
        within(active_tab)  { page.should     contain knife.headline }

        active_tab.should  have_num_tiles(2)
        archive_tab.should have_num_tiles(1)
      end
    end
  end

  describe 'Tiles appear in reverse-chronological order by activation/archived-date and then creation-date' do
    # Chronologically-speaking, creating tiles "up" from 0 to 10 and then checking "down" from 10 to 0
    let!(:tiles) do
      10.times do |i|
        tile = FactoryGirl.create :tile, demo: demo, headline: "Tile #{i}", created_at: Time.now + i.days
        # We now sort by activated_at/archived_at, and if those times aren't present we fall back on created_at
        # Make it so that all odd tiles should be listed before all even ones, and that odd/even each should be sorted in descending order.
        if i.even?
          awhile_ago = tile.created_at - 2.weeks
          tile.update_attributes(activated_at: awhile_ago, archived_at: awhile_ago)
        end
      end
    end

    it "for Active tiles" do
      expected_tile_table =
        [ ["Tile 9 Archive Edit Preview", "Tile 7 Archive Edit Preview", "Tile 5 Archive Edit Preview"],
          ["Tile 3 Archive Edit Preview", "Tile 1 Archive Edit Preview", "Tile 8 Archive Edit Preview"],
          ["Tile 6 Archive Edit Preview", "Tile 4 Archive Edit Preview", "Tile 2 Archive Edit Preview"],
          ["Tile 0 Archive Edit Preview"]
        ]
      demo.tiles.update_all status: Tile::ACTIVE

      visit tile_manager_page
      select_tab 'Active'

      table_content('#active table').should == expected_tile_table
    end

    it "for Archived tiles" do
      expected_tile_table =
        [ ["Tile 9 Activate Edit Preview", "Tile 7 Activate Edit Preview", "Tile 5 Activate Edit Preview"],
          ["Tile 3 Activate Edit Preview", "Tile 1 Activate Edit Preview", "Tile 8 Activate Edit Preview"],
          ["Tile 6 Activate Edit Preview", "Tile 4 Activate Edit Preview", "Tile 2 Activate Edit Preview"],
          ["Tile 0 Activate Edit Preview"]
        ]
      demo.tiles.update_all status: Tile::ARCHIVE

      visit tile_manager_page
      select_tab 'Archived'

      table_content('#archive table').should == expected_tile_table
    end
  end

end
