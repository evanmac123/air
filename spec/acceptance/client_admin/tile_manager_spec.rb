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
    have_link 'Archive', href: client_admin_tile_path(tile, 
      update_status: Tile::ARCHIVE)
  end

  def click_activate_link_for(tile_to_activate)    
    tile(tile_to_activate).trigger(:mouseover)
    #hack for mouseover not working poltergeist
    page.execute_script("$('.tile_buttons').show()")
    click_link href: client_admin_tile_path(tile_to_activate, 
      update_status: Tile::ACTIVE, path: :via_index)
  end
  def have_activate_link_for(tile)
    have_link 'Post', href: client_admin_tile_path(tile, 
      update_status: Tile::ACTIVE, path: :via_index)
  end

  def have_reactivate_link_for(tile)
    have_link 'Post again', href: client_admin_tile_path(tile, 
      update_status: Tile::ACTIVE, path: :via_index)
  end

  def have_edit_link_for(tile)
    have_link 'Edit', href: edit_client_admin_tile_path(tile)
  end

  def have_preview_link_for(tile)
    have_link tile.headline, href: client_admin_tile_path(tile)
  end

  def expect_tile_placeholders(section_id, expected_count)
    page.all("##{section_id} table tr:last td.odd-row-placeholder").count.should == expected_count
  end

  def expect_inactive_tile_placeholders(expected_count)
    expect_tile_placeholders("archive", expected_count)
  end

  def expect_active_tile_placeholders(expected_count)
    expect_tile_placeholders("active", expected_count)
  end

  def expect_draft_tile_placeholders(expected_count)
    expect_tile_placeholders("draft", expected_count)
  end 

  def expect_all_inactive_tile_placeholders(expected_count)
    expect_tile_placeholders("archived_tiles", expected_count)
  end

  def expect_all_draft_tile_placeholders(expected_count)
    expect_tile_placeholders("draft_tiles", expected_count)
  end
  
  def expect_page_to_be_locked
    page.should have_css('.fa-lock', visible: true)
    page.should have_content("Please create and post at least one tile to unlock this page.")
    page.should have_link 'Go to Tiles Page', client_admin_tiles_path
  end
  
  def expect_link_to_have_lock_icon(container)
    within(container) do
      page.should have_css('.fa-lock', visible: true)
    end
  end

  # -------------------------------------------------

  context 'No tiles exist for any of the types' do

    before(:each) { visit tile_manager_page }

    scenario 'Correct message is displayed when there are no Active tiles' do
      expect_content 'There are no active tiles'
      page.should have_num_tiles(0)
    end

    scenario 'Correct message is displayed when there are no Archive tiles' do
      expect_content 'There are no archived tiles'
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
      user = FactoryGirl.create :user, demo: admin.demo
      tile = FactoryGirl.create :tile, demo: admin.demo, status: Tile::ACTIVE
      tile_completion = FactoryGirl.create(:tile_completion, tile: tile, user: user)
      
      visit client_admin_share_path
      page.should have_num_tiles(4)

      # One check at this level is good enough
      tiles.each do |tile|
        within tile(tile) do
          page.should contain tile.headline
        end
      end
    end

    scenario "The tile content is correct for Archive tiles" do
      tiles.each { |tile| tile.update_attributes status: Tile::ARCHIVE }

      visit tile_manager_page
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
        visit tile_manager_page

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
        visit tile_manager_page
      end
      scenario "popup appears" do
        page.should have_css('.joyride-tip-guide', visible: true)
        page.should have_content "Click the + button to create a new tile. Need ideas? Explore"
      end
      scenario "share link on navbar shows lock icon" do
        expect_link_to_have_lock_icon('#share_tiles')
      end
      scenario "activity link on navbar shows lock icon" do
        expect_link_to_have_lock_icon('#board_activity')
      end
      scenario "activity link on navbar shows lock icon" do
        expect_link_to_have_lock_icon('#users')
      end
      scenario "hovering mouse on share link shows message" do
        page.find('#share_tiles').trigger(:mouseover)
        page.should have_content("Create and post at least one tile to unlock")
      end
      scenario "visiting share page shows lock screen with message" do
        visit client_admin_share_path
        expect_page_to_be_locked
      end
      scenario "visiting activity page shows lock screen with message" do
        visit client_admin_path
        expect_page_to_be_locked
      end
      scenario "visiting users page shows lock screen with message" do
        visit client_admin_users_path
        expect_page_to_be_locked
      end
    end
    context "when there is atleast one draft tile in demo", js: true do
      before do
        @draft_tile = FactoryGirl.create :tile, demo: admin.demo, status: Tile::DRAFT
        visit tile_manager_page
      end
      scenario "share link on navbar shows lock icon" do
        expect_link_to_have_lock_icon('#share_tiles')
      end
      scenario "activity link on navbar shows lock icon" do
        expect_link_to_have_lock_icon('#board_activity')
      end
      scenario "activity link on navbar shows lock icon" do
        expect_link_to_have_lock_icon('#users')
      end
      scenario "popup appears in first draft tile" do
        page.should have_css('.joyride-tip-guide', visible: true)
        within(".joyride-tip-guide") do
          page.should have_content("To publish, mouse over the tile and click Post")
        end
      end
      scenario "user clicks Got It, popover disappears and user nevers sees it again" do
        click_link 'Got It'
        page.should have_no_css('.joyride-tip-guide', visible: true)
      end
      scenario "popup appears under share link and then under Airbo logo after tile is activated" do
        within(".joyride-tip-guide") do
          click_link 'Got It'
        end
        click_activate_link_for(@draft_tile)
        page.should have_css('.joyride-tip-guide', visible: true)
        within(".joyride-tip-guide", visible: true) do
          page.should have_content("You've Unlocked Sharing!")
          click_link 'Got It'
        end
        page.should have_css('.joyride-tip-guide', visible: true)
        within(".joyride-tip-guide", visible: true) do
          page.should have_content("To try your board as a user click on the logo.")
        end
      end
    end
    context "when there is atleast one activated tile in demo", js: true do
      before do
        @tile = FactoryGirl.create :tile, demo: admin.demo, status: Tile::ACTIVE, creator: admin
        visit tile_manager_page
      end

      scenario "count appears near share link indicating the number tiles to be shared" do
        within('#share_tiles') do
          #in this scenario, one tile is created in 'before do' so the number
          #of tiles to be shared should be one
          page.should have_content("1")
        end
      end
      scenario "lock icon on share link doesnt appear" do
        within('#share_tiles') do
          page.should_not have_css('.fa-lock', visible: true)
        end
      end
      scenario "should receive notification for completed tile" do
        user = FactoryGirl.create :user, demo: admin.demo
        tile_completion = FactoryGirl.build(:tile_completion, tile: @tile, user: user)
        tile_completion.save!
        
        visit tile_manager_page
        page.should have_content("You've had your first user interact with a tile!")

        visit tile_manager_page
        page.should_not have_content("You've had your first user interact with a tile!")
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
        [ ["Tile 9", "Tile 7", "Tile 5", "Tile 3"],
        ["Tile 1", "Tile 8", "Tile 6", "Tile 4"],
        ["Tile 2", "Tile 0"]
      ]
      demo.tiles.update_all status: Tile::ACTIVE

      visit tile_manager_page
      table_content_without_activation_dates('#active table').should == expected_tile_table
    end

    it "for Archived tiles, showing only a limited selection of them" do
      archive_time = Time.now
      expected_tile_table =
        [ 
        ["Tile 9", "Tile 7", "Tile 5", "Tile 3"], 
        ["Tile 1", "Tile 8", "Tile 6", "Tile 4"]
      ]
      demo.tiles.update_all status: Tile::ARCHIVE
      demo.tiles.where(archived_at: nil).each{|tile| tile.update_attributes(archived_at: tile.created_at)}

      visit tile_manager_page

      table_content_without_activation_dates('#archive table').should == expected_tile_table
    end
  end

  it "has a placeholder that you can click on to create a new tile" do
    visit tile_manager_page
    click_new_tile_placeholder
    should_be_on new_client_admin_tile_path
  end

  it "pads odd rows, in both the inactive and active sections, with blank placeholder cells, so the table comes out right" do
    visit tile_manager_page

    # No tiles, except the "Add Tile" placeholder in the draft section, sooooooo...
    expect_draft_tile_placeholders(3)

    FactoryGirl.create(:tile, :draft, demo: admin.demo)
    visit tile_manager_page
    expect_draft_tile_placeholders(2)

    FactoryGirl.create(:tile, :draft, demo: admin.demo)
    visit tile_manager_page
    expect_draft_tile_placeholders(1)

    FactoryGirl.create(:tile, :draft, demo: admin.demo)
    visit tile_manager_page
    expect_draft_tile_placeholders(0)

    FactoryGirl.create(:tile, :draft, demo: admin.demo)
    visit tile_manager_page
    expect_draft_tile_placeholders(3)

    4.times { FactoryGirl.create(:tile, :draft, demo: admin.demo) }

    # There's now the creation placeholder, plus eight other draft tiles.
    # If we DID show all of them, there's be an odd row with 1 tile, and we'd
    # expect 3 placeholders. But we only show the first 8 draft tiles
    # (really the first 7 + creation placeholder) and those two rows are full 
    # now, so...
    visit tile_manager_page
    expect_draft_tile_placeholders(0)

    # And now let's do the active ones
    expect_active_tile_placeholders(0)

    FactoryGirl.create(:tile, :active, demo: admin.demo)
    visit tile_manager_page
    expect_active_tile_placeholders(3)

    FactoryGirl.create(:tile, :active, demo: admin.demo)
    visit tile_manager_page
    expect_active_tile_placeholders(2)

    FactoryGirl.create(:tile, :active, demo: admin.demo)
    visit tile_manager_page
    expect_active_tile_placeholders(1)

    FactoryGirl.create(:tile, :active, demo: admin.demo)
    visit tile_manager_page
    expect_active_tile_placeholders(0)

    FactoryGirl.create(:tile, :active, demo: admin.demo)
    visit tile_manager_page
    expect_active_tile_placeholders(3)

    #And now let's look at archived sction(It's similiar to active)
    expect_inactive_tile_placeholders(0)

    FactoryGirl.create(:tile, :archived, demo: admin.demo)
    visit tile_manager_page
    expect_inactive_tile_placeholders(3)

    FactoryGirl.create(:tile, :archived, demo: admin.demo)
    visit tile_manager_page
    expect_inactive_tile_placeholders(2)

    FactoryGirl.create(:tile, :archived, demo: admin.demo)
    visit tile_manager_page
    expect_inactive_tile_placeholders(1)

    FactoryGirl.create(:tile, :archived, demo: admin.demo)
    visit tile_manager_page
    expect_inactive_tile_placeholders(0)

    FactoryGirl.create(:tile, :archived, demo: admin.demo)
    visit tile_manager_page
    expect_inactive_tile_placeholders(3)

    4.times { FactoryGirl.create(:tile, :archived, demo: admin.demo) }

    # There's now the creation placeholder, plus eight other archived tiles.
    # If we DID show all of them, there's be an odd row with 1 tile, and we'd
    # expect 3 placeholders. But we only show the first 8 archive tiles
    # and those two rows are full 
    # now, so...
    visit tile_manager_page
    expect_inactive_tile_placeholders(0)

    # And now let's look at the full megillah of draft tiles
    visit client_admin_draft_tiles_path
    expect_all_draft_tile_placeholders(3)

    Tile.draft.last.destroy
    visit client_admin_draft_tiles_path
    expect_all_draft_tile_placeholders(0)

    Tile.draft.last.destroy
    visit client_admin_draft_tiles_path
    expect_all_draft_tile_placeholders(1)

    Tile.draft.last.destroy
    visit client_admin_draft_tiles_path
    expect_all_draft_tile_placeholders(2)

    Tile.draft.last.destroy
    visit client_admin_draft_tiles_path
    expect_all_draft_tile_placeholders(3)

    # And now let's look at the full megillah of archived tiles
    visit client_admin_inactive_tiles_path
    expect_all_inactive_tile_placeholders(3)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_all_inactive_tile_placeholders(0)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_all_inactive_tile_placeholders(1)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_all_inactive_tile_placeholders(2)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_all_inactive_tile_placeholders(3)
  end
end
