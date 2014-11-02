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
    page.should have_content "Create a new board" # slow your roll, Poltergeist  
  end

  def try_to_create_new_board(user = a_regular_user)
    visit activity_path(as: user)
    open_board_menu
    click_create_board_link
    wait_for_board_modal
    fill_in_new_board_name "Buttons"
    click_create_new_board_button
  end

  scenario "via the create-board link in das switcher", js: true do
    try_to_create_new_board

    page.should have_content "CURRENT BOARD Buttons Board"
    should_be_on client_admin_tiles_path
    page.should have_content "Click the + button to create a new tile."
  end

  scenario "and goes through the whole onboarding flow", js: true do
    user = FactoryGirl.create(:user)
    # Pretend that the user has gone through the flow at some point in the past
    user.displayed_tile_post_guide = true
    user.displayed_tile_success_guide = true
    user.save!

    try_to_create_new_board(user)
    page.should have_content "Click the + button to create a new tile."

    page.find("#add_new_tile_link").click
    fill_in_valid_form_entries
    click_create_button
    page.should have_content("Click Post to publish your tile")

    click_link "Post"
    page.should have_content("Congratulations! Your tile is posted.")

    click_link "Back to Tiles"
    page.should have_content("You've Unlocked Sharing!")

    within('.tile-index-share', visible: true) {click_link "Got It"}
    page.should have_content("To try your board as a user click on the logo.")
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
      page.should have_content "Sorry, that board name is already taken"
    end

    it "should ignore case when comparing names", js: true do
      fill_in_new_board_name "buttons"
      page.should have_content "Sorry, that board name is already taken"

      fill_in_new_board_name "BUTTONS"
      page.should have_content "Sorry, that board name is already taken"

      fill_in_new_board_name "BuTtOnS"
      page.should have_content "Sorry, that board name is already taken"
    end
  end
end
