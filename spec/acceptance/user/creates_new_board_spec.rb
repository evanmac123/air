require 'acceptance/acceptance_helper'

feature 'Create new board' do
  def new_board_lightbox_selector
    "#new_board_creation"
  end

  def click_create_board_link
    within board_menu_selector do
      click_link "Create new board"
    end
  end

  def click_create_new_board_button
    within new_board_lightbox_selector do
      click_button "Create"
    end
  end

  def fill_in_new_board_name(board_name)
    fill_in "board_name", with: board_name
  end

  def wait_for_board_modal
    page.should have_content "Make a new board" # slow your roll, Poltergeist  
  end

  scenario "create option is suppressed on mobile devices"

  scenario "via the create-board link in das switcher", js: true do
    user = FactoryGirl.create(:user)
    original_board = user.demo

    visit activity_path(as: user)
    open_board_menu
    click_create_board_link
    wait_for_board_modal

    fill_in_new_board_name "Buttons"
    click_create_new_board_button

    page.should have_content "CURRENT BOARD Buttons Board"
    should_be_on client_admin_tiles_path
    page.should have_content "Click the + button to create a new tile."
  end

  context "with a name that's already taken" do
    before do
      FactoryGirl.create(:demo, name: "Buttons Board")
      visit activity_path(as: a_regular_user)
      open_board_menu
      click_create_board_link
      wait_for_board_modal

      fill_in_new_board_name "Buttons"
    end

    it "should warn the user", js: true do
      page.should have_content "Sorry, that board name is already taken"
    end

    it "should have a little X in the field"

    it "should not allow submission"
  end
end
