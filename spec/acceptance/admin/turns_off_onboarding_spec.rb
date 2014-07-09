require 'acceptance/acceptance_helper'

feature 'Admin turns off onboarding', :js => true do

  def check_turn_off_onboarding_flag
    page.find("#demo_turn_off_admin_onboarding_input").click
  end

  def expect_no_lock_icon
    page.should_not have_css('.fa-lock')
  end

  def expect_page_to_be_not_locked
    page.should_not have_css('.fa-lock', visible: true)
    page.should_not have_content("Please create and post at least one tile to unlock this page.")
    page.should_not have_link 'Go to Tiles Page', client_admin_tiles_path
  end

  scenario "should do this on the edit board page" do
    demo = FactoryGirl.create(:demo)
    demo.turn_off_admin_onboarding.should == false
    
    visit edit_admin_demo_path(demo, as: an_admin)
    expect_content "Turn off admin onboarding"
    
    check_turn_off_onboarding_flag
    click_button "Update Game"
    
    expect_content "Demo updated"
    demo.reload.turn_off_admin_onboarding.should == true
  end

  context "New client admin comes without onboarding" do
    before(:each) do
      @demo = FactoryGirl.create(:demo, :with_turned_off_onboarding)
      @admin = FactoryGirl.create(:client_admin, demo: @demo)

      bypass_modal_overlays(@admin)
      signin_as(@admin, @admin.password)
    end
    context "visits client_admin/tiles page " do
      scenario "should see create new tile popup", js: true do
        visit tile_manager_page
        expect_content "Draft"
        page.should have_css('.joyride-tip-guide', visible: true)
        page.should have_content "Click the + button to create a new tile. Need ideas? Explore"
      end

      scenario "when there is atleast one draft tile in demo should not see pop up", js: true do
        @draft_tile = FactoryGirl.create :tile, demo: @admin.demo, status: Tile::DRAFT
        visit tile_manager_page
        page.should_not have_css('.joyride-tip-guide', visible: true)
        page.should_not have_content("To publish, mouse over the tile and click Post")
        page.should_not have_content("To try your board as a user click on the logo.")
      end

      scenario "should not receive notification for completed tile", js: true do
        @tile = FactoryGirl.create :tile, demo: @admin.demo, status: Tile::ACTIVE, creator: @admin
        FactoryGirl.create :tile, demo: @admin.demo, status: Tile::ACTIVE, creator: @admin        
        
        user = FactoryGirl.create :user, demo: @admin.demo
        tile_completion = FactoryGirl.build(:tile_completion, tile: @tile, user: user)
        tile_completion.save!

        visit tile_manager_page

        page.should_not have_content("You've had your first user interact with a tile!")
      end

      scenario "should not have any lock" do
        expect_no_lock_icon
      end
    end
    context "visiting share page" do
      scenario "sholud not show lock screen" do
        visit client_admin_share_path
        expect_page_to_be_not_locked
        expect_content "Send Email with New Tiles Tiles that you activate will appear here so you can share them with users in a digest email"
      end

      scenario "sholud not show invite users screen" do
        expect_no_content "Invite people to your board "
      end
    end
    scenario "visiting activity page should not show lock screen with message" do
      visit client_admin_path
      expect_page_to_be_not_locked
      expect_content "Stats"
    end
    scenario "visiting users page should not show lock screen with message" do
      visit client_admin_users_path
      expect_page_to_be_not_locked
      expect_content "Upload Users"
    end
  end
end