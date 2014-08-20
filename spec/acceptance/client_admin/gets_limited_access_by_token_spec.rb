require 'acceptance/acceptance_helper'

feature 'Client admin gets limited access by token' do
  let(:client_admin) do 
    admin = FactoryGirl.create(:client_admin)
    admin.password = admin.password_confirmation = "foobar"
    admin.save!
    admin
  end

  def wait_for_login_modal
    page.should have_content("For security purposes")
  end

  def click_login_button
    click_button 'Confirm Password'
  end

  def expect_login_modal(expected_email)
    page.should have_content("For security purposes please confirm your password. Not #{expected_email}? Log in or create a board here")
  end

  def click_board_switcher
    page.find('#board_switch_toggler').click
  end

  def open_user_dropdown
    page.find('#me_toggle').click
  end

  scenario "to the explore page, when the token is appended as a query parameter" do
    visit explore_path(explore_token: client_admin.explore_token)

    should_be_on explore_path
  end

  scenario "to the tile tag page, when the token is appended as a query parameter" do
    tile_tag = FactoryGirl.create(:tile_tag)
    visit tile_tag_show_explore_path(tile_tag: tile_tag, explore_token: client_admin.explore_token)

    should_be_on tile_tag_show_explore_path
  end

  scenario "to the random-tile page, when the token is appended as a query parameter" do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)
    visit explore_random_tile_path(explore_token: client_admin.explore_token)
    should_be_on explore_tile_preview_path(tile)
  end

  scenario "when they log in by token in a query parameter, they don't have to keep appending it in subsequent requests" do
    tile_tag = FactoryGirl.create(:tile_tag)

    visit explore_path(explore_token: client_admin.explore_token)
    visit tile_tag_show_explore_path(tile_tag: tile_tag)

    should_be_on tile_tag_show_explore_path
  end

  scenario "can like a tile when logged in by token", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)

    visit explore_path(explore_token: client_admin.explore_token)

    click_link "Vote Up"
    page.should have_content("Voted Up")
  end

  scenario "can copy a tile when logged in by token", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public, :copyable)
    crank_dj_clear # resize tile images, otherwise copy blows up
    tile.reload

    visit explore_path(explore_token: client_admin.explore_token)

    click_link "Copy"
    page.should have_content("Copied")
  end

  scenario "can't go outside the explore family using a token in the query parameter" do
    visit activity_path(explore_token: client_admin.explore_token)
    should_be_on sign_in_path
  end

  scenario "can't go outside the explore family using a token in the session" do
    visit explore_path(explore_token: client_admin.explore_token)
    visit activity_path(explore_token: client_admin.explore_token)
    should_be_on sign_in_path
  end

  scenario "if they happen to be in another board as a peon, they can still log in via explore token" do
    board = FactoryGirl.create(:demo)
    client_admin.add_board(board)
    client_admin.move_to_new_demo(board)

    client_admin.reload.is_client_admin.should be_false

    visit explore_path(explore_token: client_admin.explore_token)
    should_be_on explore_path
  end

  describe 'the login modal' do
    def expect_login_modal_after
      visit explore_path(explore_token: client_admin.explore_token)
      
      yield

      page.all('.other_boards', visible: true).should be_empty
      expect_login_modal(client_admin.email)
    end

    def login_modal_goes_to(expected_path)
      fill_in "session_password", with: "foobar"
      click_login_button
      should_be_on expected_path
    end

    scenario "the board switcher is nerfed and pops a login modal instead", js: true do
      expect_login_modal_after do
        click_board_switcher
      end
    end

    scenario "the Manage link in the header is nerfed", js: true do
      expect_login_modal_after do
        click_link "manage_board"
      end

      login_modal_goes_to client_admin_tiles_path
    end

    scenario "the link over the logo is nerfed", js: true do
      expect_login_modal_after do
        page.find('#top_bar #logo a').click
      end

      login_modal_goes_to activity_path
    end

    scenario "Manage My board link in post-copy modal is nerfed", js: true do
      FactoryGirl.create(:multiple_choice_tile, :public, :copyable)
      crank_dj_clear # for image resizing

      expect_login_modal_after do
        page.first('.copy_tile_link').click
        page.should have_content("Manage Your Board")
        within("#post_copy_buttons") {click_link "Manage Your Board"}
      end

      login_modal_goes_to client_admin_tiles_path
    end

    scenario "Edit link in post-copy modal is nerfed", js: true do
      FactoryGirl.create(:multiple_choice_tile, :public, :copyable)
      crank_dj_clear # for image resizing

      expect_login_modal_after do
        page.first('.copy_tile_link').click
        page.should have_content("Manage Your Board")
        within("#post_copy_buttons") {click_link "Edit"}
      end

      login_modal_goes_to edit_client_admin_tile_path(Tile.last.id)
    end

    scenario "find-users link in dropdown is nerfed", js: true do
      expect_login_modal_after do
        open_user_dropdown
        click_link "Find users"
      end

      login_modal_goes_to users_path
    end

    scenario "settings link in dropdown is nerfed", js: true do
      expect_login_modal_after do
        open_user_dropdown
        click_link "Settings"
      end

      login_modal_goes_to edit_account_settings_path
    end

    scenario "my-profile link in dropdown is nerfed", js: true do
      expect_login_modal_after do
        open_user_dropdown
        click_link "My Profile"
      end

      login_modal_goes_to user_path(client_admin)
    end

    scenario 'allows login by entering a password', js: true do
      client_admin.password = client_admin.password_confirmation = 'foobar'
      client_admin.save!

      visit explore_path(explore_token: client_admin.explore_token)
      click_board_switcher
      wait_for_login_modal

      within '#login_modal' do
        fill_in "session[password]", with: 'foobar'
        click_login_button
      end
      
      should_be_on activity_path(format: 'html')
    end

    scenario 'has link to login page', js: true do
      visit explore_path(explore_token: client_admin.explore_token)
      click_board_switcher
      wait_for_login_modal

      within('#login_modal') { click_link 'Log in' }
      should_be_on new_session_path
    end

    scenario 'has link to boards/new', js: true do
      visit explore_path(explore_token: client_admin.explore_token)
      click_board_switcher
      wait_for_login_modal

      within('#login_modal') { click_link 'create a board here' }
      should_be_on new_board_path
    end
  end
end
