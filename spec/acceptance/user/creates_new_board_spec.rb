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
    page.find("#new_board_creation").click
  end

  def try_to_create_new_board(user = a_regular_user)
    visit activity_path(as: user)
    open_board_menu
    click_create_board_link
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
end
