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

  scenario "create option is suppressed on mobile devices"

  scenario "via the create-board link in das switcher", js: true do
    user = FactoryGirl.create(:user)
    original_board = user.demo

    visit activity_path(as: user)
    open_board_menu
    click_create_board_link
    page.should have_content "Make a new board" # slow your roll, Poltergeist

    fill_in_new_board_name "Buttons"
    click_create_new_board_button

    page.should have_content "CURRENT BOARD Buttons Board"
    should_be_on client_admin_tiles_path
    page.should have_content "Click the + button to create a new tile."
  end

  context "with a name that's already taken" do
    it "should warn the user"
    it "should not allow submission"
  end
end
