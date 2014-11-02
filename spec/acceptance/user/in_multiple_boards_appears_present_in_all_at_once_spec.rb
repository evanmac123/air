require 'acceptance/acceptance_helper'

feature 'In multiple boards appears present in all at once' do
  USER_NAME = "Mister Multiple"

  def create_two_boards(*args)
    @first_board = FactoryGirl.create(:demo, *args)
    @second_board = FactoryGirl.create(:demo, *args)
  end

  def create_user
    @user = FactoryGirl.create(:user, :claimed, name: USER_NAME, demo: @first_board)
    @user.add_board(@second_board)
  end

  def create_two_admins
    @first_admin = FactoryGirl.create(:client_admin, demo: @first_board)
    @second_admin = FactoryGirl.create(:client_admin, demo: @second_board)
  end

  def first_tile_headline(board)
    board.tiles.first.headline
  end

  def expect_all_headlines_in_some_email(user, *boards)
    emails_to_user = ActionMailer::Base.deliveries.select{|email| email.to.include?(user.email)}
    headlines = boards.map{|board| first_tile_headline(board)}
    headlines.all?{|headline| emails_to_user.any? {|email_to_user| email_to_user.html_part.body.to_s.include?(headline)} }.should be_true
  end

  context "in client/site admin searches for users" do
    before do
      create_two_boards(:activated)
      create_two_admins
      create_user

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

      create_user
    end

    after do
      Timecop.return
    end

    scenario "digests are received from both" do
      visit client_admin_share_path(as: @first_admin)
      click_button "Send"
      crank_dj_clear

      open_email(@user.email)
      current_email.html_part.body.should include(first_tile_headline(@first_board))
      visit_in_email "Your New Tiles Are Here!"
      should_be_on activity_path
      expect_current_board_header @first_board

      ActionMailer::Base.deliveries.clear

      visit client_admin_share_path(as: @second_admin)
      click_button "Send"
      crank_dj_clear

      open_email(@user.email)
      current_email.html_part.body.should include(first_tile_headline(@second_board))
      visit_in_email "Your New Tiles Are Here!"
      should_be_on activity_path
      expect_current_board_header @second_board
    end

    scenario "followups are received from both" do
      Timecop.freeze
      Timecop.travel(Chronic.parse("March 23, 2014, 12:00 PM")) # a Sunday
      visit client_admin_share_path(as: @first_admin)
      select "Tuesday", from: "follow_up_day"
      click_button "Send"
      crank_dj_clear

      visit client_admin_share_path(as: @second_admin)
      select "Tuesday", from: "follow_up_day"
      click_button "Send"
      crank_dj_clear

      Timecop.travel(Chronic.parse("March 25, 2014, 6:00 PM"))
      # pretend to be the cron job that schedules, in the wee hours of every 
      # morning, the followup emails to be sent that day.
      TilesDigestMailer.notify_all_follow_up_from_delayed_job
      ActionMailer::Base.deliveries.clear
      crank_dj_clear

      expect_all_headlines_in_some_email(@user, @first_board, @second_board)
    end

    scenario "existing user is invited from a new board gets non-broken digest", js: true do
      # detects a regression that Kate found in testing
      visit new_board_path
      fill_in "user[name]", with: "New Guy"
      fill_in "user[email]", with: "new@guy.com"
      fill_in "user[password]", with: "grunty"
      fill_in "board[name]", with: "terrible annoyance"
      click_button "Create Board"

      page.find("#add_new_tile_link").click
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
      current_email.html_part.body.should include(@tile.headline)
    end
  end
end
