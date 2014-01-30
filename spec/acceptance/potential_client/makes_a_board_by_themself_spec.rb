require 'acceptance/acceptance_helper'

feature 'Makes a board by themself' do
  NEW_CREATOR_NAME = "Johnny Cochran"
  NEW_CREATOR_EMAIL = "mustacquit@cochranlaw.com"
  NEW_CREATOR_PASSWORD = "ojtotallydidit"
  NEW_BOARD_NAME = "Law Offices Of J. Cochran"

  def fill_in_valid_form_entries
    fill_in 'user[name]', with: NEW_CREATOR_NAME
    fill_in 'user[email]', with: NEW_CREATOR_EMAIL
    fill_in 'user[password]', with: NEW_CREATOR_PASSWORD
    fill_in 'board[name]', with: NEW_BOARD_NAME
  end

  def submit_create_form
    click_button "Create Board"
  end

  before do
    visit new_board_path
  end

  context 'the happy path' do
    before do
      fill_in_valid_form_entries
      submit_create_form
      @new_board = Demo.order("created_at DESC").first
    end

    it 'should have created a new board with reasonable defaults' do
      # A purist will tell you not to delve into the DB in an acceptance test
      # but instead to only look at effects visible to the end user. But if we
      # do that this test would be five times as long and ten times as 
      # brittle. Also I don't hire purists.

      @new_board.name.should == NEW_BOARD_NAME
      @new_board.game_referrer_bonus.should == 5
      @new_board.referred_credit_bonus.should == 2
      @new_board.credit_game_referrer_threshold.should == 100000
      @new_board.email.should == "lawofficesofjcochran@ourairbo.com"
    end

    it 'should have created a new creator' do
      @new_board.should have(1).user

      new_creator = @new_board.users.first
      new_creator.is_client_admin.should be_true
      new_creator.is_site_admin.should be_false # just so I can sleep at night
      new_creator.cancel_account_token.should_not be_nil

      new_creator.name.should == NEW_CREATOR_NAME
      new_creator.email.should == NEW_CREATOR_EMAIL
      new_creator.should be_claimed

      visit sign_in_path
      fill_in "session[email]", with: NEW_CREATOR_EMAIL
      fill_in "session[password]", with: NEW_CREATOR_PASSWORD

      click_button "Log In"
      should_be_on activity_path(format: 'html')
    end

    it 'should leave them on the client admin tile path' do
      should_be_on client_admin_tiles_path
    end

    it 'should send a confirmation email to the new creator' do
      crank_dj_clear
      open_email NEW_CREATOR_EMAIL

      current_email.to_s.should include(NEW_BOARD_NAME)
      current_email.to_s.should include(@new_board.users.first.cancel_account_token)
    end
  end

  context 'when there are problems with the input' do
    it "should show an error for a non-unique board name" do
      FactoryGirl.create(:demo, name: NEW_BOARD_NAME)
      Demo.count.should == 1
      fill_in_valid_form_entries
      submit_create_form

      should_be_on boards_path
      expect_content "Sorry, we weren't able to create your board: the board name has already been taken."
    end

    it "should show an error for a blank board name" do
      fill_in_valid_form_entries
      fill_in 'board[name]', with: ''
      submit_create_form

      should_be_on boards_path
      expect_content "Sorry, we weren't able to create your board: the board name can't be blank."
    end

    it "should show an error for a blank user name" do
      fill_in_valid_form_entries
      fill_in 'user[name]', with: ''
      submit_create_form

      should_be_on boards_path
      expect_content "Sorry, we weren't able to create your board: user name can't be blank."
    end

    it "should show an error for a blank user email" do
      fill_in_valid_form_entries
      fill_in 'user[email]', with: ''
      submit_create_form

      should_be_on boards_path
      expect_content "Sorry, we weren't able to create your board: user email can't be blank."
    end

    it "should show an error for a non-unique user email" do
      FactoryGirl.create(:user, email: NEW_CREATOR_EMAIL)
      fill_in_valid_form_entries
      submit_create_form

      should_be_on boards_path
      expect_content "Sorry, we weren't able to create your board: user email has already been taken"
    end

    it "should have reasonable errors for missing password" do
      fill_in_valid_form_entries
      fill_in "user[password]", with: ''
      submit_create_form

      should_be_on boards_path
      expect_content "Sorry, we weren't able to create your board: please enter a password at least 6 characters long"
    end

    it "should display user errors even if the board has errors" do
      fill_in_valid_form_entries
      fill_in "board[name]", with: ''
      fill_in "user[name]", with: ''
      submit_create_form

      should_be_on boards_path
      expect_content "Sorry, we weren't able to create your board: the board name can't be blank, user name can't be blank"
    end

    it "should retain values for both user and board on failure" do
      FactoryGirl.create(:demo, name: NEW_BOARD_NAME)
      FactoryGirl.create(:user, name: NEW_CREATOR_NAME)
      
      fill_in_valid_form_entries
      submit_create_form

      should_be_on boards_path

      page.find('#board_name').value.should == NEW_BOARD_NAME
      page.find('#user_name').value.should == NEW_CREATOR_NAME
      page.find('#user_email').value.should == NEW_CREATOR_EMAIL
      page.find('#user_password').value.should == NEW_CREATOR_PASSWORD
    end

    it "should not leave a board hanging around if the board is valid but the user isn't" do
      fill_in_valid_form_entries
      fill_in "user[name]", with: ''

      Demo.count.should be_zero
      User.count.should be_zero

      submit_create_form

      Demo.count.should be_zero
      User.count.should be_zero
    end
  end
end
