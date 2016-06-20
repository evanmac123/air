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
    expect_content "Create a new board" # slow your roll, Poltergeist  
  end

  def try_to_create_new_board(user = a_regular_user)
    visit activity_path(as: user)
    open_board_menu
    click_create_board_link
    wait_for_board_modal
    fill_in_new_board_name "Buttons"
    click_create_new_board_button
  end

  def board_name_taken_message
    "Sorry, that board name is already taken".upcase
  end

  scenario "via the create-board link in das switcher", js: true do
    try_to_create_new_board

    expect_content "CURRENT BOARD Buttons Board"
    should_be_on client_admin_tiles_path
  end

  context "with a name that's already taken" do
    before do
      FactoryGirl.create(:demo, name: "Buttons Board")
      visit activity_path(as: a_regular_user)
      open_board_menu
      click_create_board_link
      wait_for_board_modal
    end

    it "should warn the user", js: true do
      fill_in_new_board_name "Buttons"
      expect_content board_name_taken_message
    end

    it "should ignore case when comparing names", js: true do
      fill_in_new_board_name "buttons"
      expect_content board_name_taken_message

      fill_in_new_board_name "BUTTONS"
      expect_content board_name_taken_message

      fill_in_new_board_name "BuTtOnS"
      expect_content board_name_taken_message
    end
  end
end
