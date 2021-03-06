require 'acceptance/acceptance_helper'

xfeature 'In multiple boards appears present in all at once' do
  USER_NAME = "Mister Multiple"

  def create_two_boards(*args)
    @first_board = FactoryBot.create(:demo, *args)
    @second_board = FactoryBot.create(:demo, *args)
  end

  def create_user
    @user = FactoryBot.create(:user, :claimed, name: USER_NAME, demo: @first_board)
    @user.add_board(@second_board)
  end

  def create_two_admins
    @first_admin = FactoryBot.create(:client_admin, demo: @first_board)
    @second_admin = FactoryBot.create(:client_admin, demo: @second_board)
  end

  def first_tile_headline(board)
    board.tiles.first.headline
  end

  def submit_button
    page.find("#tiles_digest_form input[type='submit']")
  end

  context "in client/site admin searches for users" do
    before do
      create_two_boards(:activated)
      create_two_admins
      create_user

      expect(@user.demos.size).to eq(2)
      expect(@user.demo).to eq(@first_board)
    end

    scenario 'appears in client admin search results for all demos', js: true do
      visit client_admin_users_path(as: @first_admin)
      click_link "Show everyone"
      expect(page).to have_content(USER_NAME)

      visit client_admin_users_path(as: @second_admin)
      click_link "Show everyone"
      expect(page).to have_content(USER_NAME)
    end

    scenario 'appears in site admin search results for all demos' do
      visit admin_demo_path(@first_board, as: an_admin)
      click_link "Everyone"
      expect(page).to have_content(USER_NAME)
      visit admin_demo_path(@second_board, as: an_admin)
      click_link "Everyone"
      expect(page).to have_content(USER_NAME)
    end
  end

  context "in connection lists of friends" do
    it "should appear regardless of which board you look from" do
      @first_friend = FactoryBot.create(:user)
      @second_friend = FactoryBot.create(:user)
      @random_dude = FactoryBot.create(:user)

      @user = FactoryBot.create(:user, demo: @first_friend.demo, name: USER_NAME)
      @user.add_board(@second_friend.demo)

      @user.befriend(@first_friend)
      @user.befriend(@second_friend)
      @first_friend.accept_friendship_from(@user)
      @second_friend.accept_friendship_from(@user)

      visit activity_path(as: @first_friend)
      expect(page).to have_content(USER_NAME)

      visit activity_path(as: @second_friend)
      expect(page).to have_content(USER_NAME)

      visit activity_path(as: @random_dude)
      expect(page).not_to have_content(USER_NAME)
    end
  end

  context "sending digests and followups from different boards" do
    before do
      create_two_boards(:activated)
      create_two_admins
      Tile.all.each { |tile| FactoryBot.create(:tile_completion, tile: tile) } # gets us past the "invite users" share screen

      create_user
    end

    after do
      Timecop.return
    end

    scenario "digests are received from both" do
      visit client_admin_share_path(as: @first_admin)
      submit_button.click

      open_email(@user.email)
      expect(current_email.body).to include(first_tile_headline(@first_board))
      visit(current_email.body.raw_source.split('<a')[1].split('href="')[1].split('">')[0])
      should_be_on activity_path
      expect_current_board_header @first_boardz

      ActionMailer::Base.deliveries.clear

      visit client_admin_share_path(as: @second_admin)
      submit_button.click

      open_email(@user.email)
      expect(current_email.body).to include(first_tile_headline(@second_board))
      visit(current_email.body.raw_source.split('<a')[1].split('href="')[1].split('">')[0])
      should_be_on activity_path
      expect_current_board_header @second_board
    end
  end
end
