require 'acceptance/acceptance_helper'

feature 'In multiple boards appears present in all at once' do
  USER_NAME = "Mister Multiple"

  def create_two_boards(*args)
    @first_board = FactoryGirl.create(:demo, *args)
    @second_board = FactoryGirl.create(:demo, *args)
  end

  def create_two_admins
    @first_admin = FactoryGirl.create(:client_admin, demo: @first_board)
    @second_admin = FactoryGirl.create(:client_admin, demo: @second_board)
  end

  context "in client/site admin searches for users" do
    before do
      create_two_boards(:activated)
      create_two_admins

      @user = FactoryGirl.create(:user, name: USER_NAME, demo: @first_board)
      @user.add_board(@second_board)

      @user.demos.should have(2).demos
      @user.demo.should == @first_board
    end

    scenario 'appears in client admin search results for all demos', js: true do
      visit client_admin_users_path(as: @first_admin)
      click_link "Show everyone"
      page.should have_content(USER_NAME)

      visit client_admin_users_path(as: @second_admin)
      click_link "Show everyone"
      page.should have_content(USER_NAME)
    end

    scenario 'appears in site admin search results for all demos' do
      visit admin_demo_path(@first_board, as: an_admin)
      click_link "Everyone"
      page.should have_content(USER_NAME)
      visit admin_demo_path(@second_board, as: an_admin)
      click_link "Everyone"
      page.should have_content(USER_NAME)
    end
  end

  context "in connection lists of friends" do
    it "should appear regardless of which board you look from" do
      @first_friend = FactoryGirl.create(:user)
      @second_friend = FactoryGirl.create(:user)
      @random_dude = FactoryGirl.create(:user)

      @user = FactoryGirl.create(:user, demo: @first_friend.demo, name: USER_NAME)
      @user.add_board(@second_friend.demo)

      @user.befriend(@first_friend)
      @user.befriend(@second_friend)
      @first_friend.accept_friendship_from(@user)
      @second_friend.accept_friendship_from(@user)

      visit activity_path(as: @first_friend)
      page.should have_content(USER_NAME)

      visit activity_path(as: @second_friend)
      page.should have_content(USER_NAME)

      visit activity_path(as: @random_dude)
      page.should_not have_content(USER_NAME)
    end
  end

  context "sending digests and followups from different boards" do
    before do
      create_two_boards(:activated)
      create_two_admins
      Tile.all.each { |tile| FactoryGirl.create(:tile_completion, tile: tile) } # gets us past the "invite users" share screen
      
      @user = FactoryGirl.create(:user, demo: @first_board, name: USER_NAME)
      @user.add_board(@second_board)
    end

    scenario "digests are received from both" do
      visit client_admin_share_path(as: @first_admin)
      click_button "Send digest now"
      visit client_admin_share_path(as: @second_admin)
      click_button "Send digest now"
      pending "should work"
    end

    scenario "followups are received from both"

    scenario "existing user is invited from a new board gets non-broken digest", js: true do
      # detects a regression that Kate found in testing
      visit new_board_path
      fill_in "user[name]", with: "New Guy"
      fill_in "user[email]", with: "new@guy.com"
      fill_in "user[password]", with: "grunty"
      fill_in "board[name]", with: "terrible annoyance"
      click_button "Create Board"

      click_link "Add New Tile"
      create_good_tile
      # cheat a little...
      @tile = Tile.last
      @tile.update_attributes(headline: "Canary in a coal mine")

      click_link "Post"
      click_link "Back to Tiles"
      click_link "Share 1"

      fill_in "user_0_name", with: USER_NAME
      fill_in "user_0_email", with: @user.email
      click_link "Preview Invitation"

      click_link "Send"
      crank_dj_clear

      open_email(@user.email)
      current_email.body.should include(@tile.headline)
    end
  end
end
