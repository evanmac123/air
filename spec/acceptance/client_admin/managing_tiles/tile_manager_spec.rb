require 'acceptance/acceptance_helper'

feature 'Client admin and tile manager page' do
  include TileManagerHelpers
  include WaitForAjax

  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  context 'No tiles exist for any of the types' do

    before(:each) { visit_tile_manager_page }

    scenario 'Correct message is displayed when there are no Active tiles' do
      page.find("#active .no_tiles_section", visible: true).should be_present
      page.should have_num_tiles(0)
    end

    scenario 'Correct message is displayed when there are no Archive tiles' do
      page.find("#active .no_tiles_section", visible: true).should be_present
      page.should have_num_tiles(0)
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

      visit_tile_manager_page
      
      expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
      
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

    scenario "The tile content is correct for Archive tiles" do
      tiles.each { |tile| tile.update_attributes status: Tile::ARCHIVE }

      visit_tile_manager_page
      expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
      
      page.should have_num_tiles(3)

      tiles.each do |tile|
        within tile(tile) do
          page.should contain tile.headline
          page.should have_reactivate_link_for(tile)
        end
      end
    end

    context 'Archiving and activating tiles' do
      scenario "The 'Archive this tile' links work, including setting the 'archived_at' time and positioning most-recently-archived tiles first" do
        tiles.each { |tile| tile.update_attributes status: Tile::ACTIVE }
        visit_tile_manager_page
        expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')

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

        # Do it one more time to make sure that the most-recently archived tile appears first in the list
        knife.archived_at.should be_nil

        active_tab.find(:tile, knife).click_link('Archive')
        page.should contain "The #{knife.headline} tile has been archived"

        knife.reload.archived_at.sec.should be_within(1).of(Time.now.sec)

        within(active_tab)  { page.should_not contain knife.headline }
        within(archive_tab) { page.should     contain knife.headline }

        active_tab.should  have_num_tiles(1)
        archive_tab.should have_num_tiles(2)

        archive_tab.should have_first_tile(knife, Tile::ARCHIVE)
      end

      scenario "The 'Activate this tile' links work, including setting the 'activated_at' time and positioning most-recently-activated tiles first" do
        tiles.each { |tile| tile.update_attributes status: Tile::ARCHIVE }
        visit_tile_manager_page
        expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')

        active_tab.should  have_num_tiles(0)
        archive_tab.should have_num_tiles(3)

        archive_tab.find(:tile, kill).click_link('Post again')
        page.should contain "The #{kill.headline} tile has been published"

        kill.reload.activated_at.sec.should be_within(1).of(Time.now.sec)

        within(archive_tab) { page.should_not contain kill.headline }
        within(active_tab)  { page.should     contain kill.headline }

        active_tab.should  have_num_tiles(1)
        archive_tab.should have_num_tiles(2)

        # Do it one more time to make sure that the most-recently activated tile appears first in the list
        archive_tab.find(:tile, knife).click_link('Post again')
        page.should contain "The #{knife.headline} tile has been published"

        knife.reload.activated_at.sec.should be_within(1).of(Time.now.sec)

        within(archive_tab) { page.should_not contain knife.headline }
        within(active_tab)  { page.should     contain knife.headline }

        active_tab.should  have_num_tiles(2)
        archive_tab.should have_num_tiles(1)

        active_tab.should have_first_tile(knife, Tile::ACTIVE)
      end
    end
  end
  
  context "New client admin visits client_admin/tiles page" do
    context "For new client admin, when there is no tile in the demo", js: true do
      before do
        visit_tile_manager_page
      end
      scenario "popup appears" do
        page.should have_css('.joyride-tip-guide', visible: true)
        page.should have_content "Click the + button to create a new tile. Need ideas? Explore"
      end
    end

    context "when there is atleast one activated tile in demo", js: true do
      before do
        @tile = FactoryGirl.create :tile, demo: admin.demo, status: Tile::ACTIVE, creator: admin
        FactoryGirl.create :tile, demo: admin.demo, status: Tile::ACTIVE, creator: admin        
        visit_tile_manager_page
      end

      scenario "count appears near share link indicating the number tiles to be shared" do
        within('#share_tiles') do
          #in this scenario, one tile is created in 'before do' so the number
          #of tiles to be shared should be one
          page.should have_content("2")
        end
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
        [
          "Tile 9", "Tile 7", "Tile 5", "Tile 3",
          "Tile 1", "Tile 8", "Tile 6", "Tile 4",
          "Tile 2", "Tile 0"
        ]
      expected_tile_table.reverse.each do|tile| 
        demo.tiles.find_by_headline(tile).update_status(Tile::ACTIVE)
      end

      visit_tile_manager_page
      expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
      
      section_content_without_activation_dates('#active').should == expected_tile_table
    end

    it "for Archived tiles, showing only a limited selection of them" do
      expected_tile_table =
        [ 
          "Tile 9", "Tile 7", "Tile 5", "Tile 3", 
          "Tile 1", "Tile 8", "Tile 6", "Tile 4",
          "Tile 2", "Tile 0"
        ]
      expected_tile_table.reverse.each do|tile| 
        demo.tiles.find_by_headline(tile).update_status(Tile::ARCHIVE)
      end

      visit_tile_manager_page
      expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')

      section_content_without_activation_dates('#archive').should == expected_tile_table[0..3]
    end
  end

  it "has a placeholder that you can click on to create a new tile" do
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    
    click_new_tile_placeholder
    should_be_on new_client_admin_tile_path
    
    expect_mixpanel_action_ping('Tiles Page', 'Clicked Add New Tile')
  end

  it "pads odd rows, in both the inactive and active sections, with blank placeholder cells, so the table comes out right", js: true do
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')

    # No tiles, except the "Add Tile" placeholder in the draft section, sooooooo...
    expect_draft_tile_placeholders(3)

    FactoryGirl.create(:tile, :draft, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_draft_tile_placeholders(2)

    FactoryGirl.create(:tile, :draft, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_draft_tile_placeholders(1)

    FactoryGirl.create(:tile, :draft, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_draft_tile_placeholders(0)

     # There's now the creation placeholder, plus 4 other draft tiles.
    # If we DID show all of them, there's be an odd row with 1 tile, and we'd
    # expect 3 placeholders. But we only show the first 4 draft tiles
    # (really the first 3 + creation placeholder) and those two rows are full 
    # now, so...
    FactoryGirl.create(:tile, :draft, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_draft_tile_placeholders(0)

    # And now let's do the active ones
    expect_active_tile_placeholders(0)

    FactoryGirl.create(:tile, :active, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_active_tile_placeholders(3)

    FactoryGirl.create(:tile, :active, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_active_tile_placeholders(2)

    FactoryGirl.create(:tile, :active, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_active_tile_placeholders(1)

    FactoryGirl.create(:tile, :active, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_active_tile_placeholders(0)

    FactoryGirl.create(:tile, :active, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_active_tile_placeholders(3)

    #And now let's look at archived sction(It's similiar to active)
    expect_inactive_tile_placeholders(0)

    FactoryGirl.create(:tile, :archived, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_inactive_tile_placeholders(3)

    FactoryGirl.create(:tile, :archived, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_inactive_tile_placeholders(2)

    FactoryGirl.create(:tile, :archived, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_inactive_tile_placeholders(1)

    FactoryGirl.create(:tile, :archived, demo: admin.demo)
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_inactive_tile_placeholders(0)
    5.times { FactoryGirl.create(:tile, :archived, demo: admin.demo) }

    # There's now the creation placeholder, plus eight other archived tiles.
    # If we DID show all of them, there's be an odd row with 1 tile, and we'd
    # expect 3 placeholders. But we only show the first 8 archive tiles
    # and those two rows are full 
    # now, so...
    visit_tile_manager_page
    expect_mixpanel_page_ping('viewed page', 'Manage - Tiles')
    expect_inactive_tile_placeholders(0)

    # And now let's look at the full megillah of archived tiles
    visit client_admin_inactive_tiles_path
    expect_inactive_tile_placeholders(3)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_inactive_tile_placeholders(0)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_inactive_tile_placeholders(1)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_inactive_tile_placeholders(2)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_inactive_tile_placeholders(3)
  end
end
