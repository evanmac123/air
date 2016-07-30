require 'acceptance/acceptance_helper'

feature 'Switches boards' do
  def expect_only_tile_headlines_in(board)
    expected_tiles = board.tiles
    unexpected_tiles = Tile.all - expected_tiles

    expected_tiles.each do |expected_tile|
      page.should have_content(expected_tile.headline)
    end

    unexpected_tiles.each do |unexpected_tile|
      page.should_not have_content(unexpected_tile.headline)
    end
  end

  context "via the desktop menu" do
    context "when in multiple boards" do
      before do
        @user = FactoryGirl.create(:user)
        @first_board = @user.demo

        @second_board = FactoryGirl.create(:demo)
        @third_board = FactoryGirl.create(:demo)
        @user.add_board(@second_board)
        @user.add_board(@third_board)

        visit activity_path(as: @user)
      end

      it "shows the name of the current board" do
        expect_current_board_header(@first_board)
      end

      it "shows all non-current boards in the switch menu", js: true do
        open_board_menu
        within(board_menu_selector) do
          page.should_not have_content(@first_board.name)
          page.should have_content(@second_board.name)
          page.should have_content(@third_board.name)
        end
      end

      it "allows switching between them" do
        [@first_board, @second_board, @third_board].each do |board|
          FactoryGirl.create(:multiple_choice_tile, demo: board, status: Tile::ACTIVE)
        end

        visit activity_path(as: @user)
        expect_only_tile_headlines_in(@first_board)

        open_board_menu
        click_link @second_board.name
        expect_only_tile_headlines_in(@second_board)

        open_board_menu
        click_link @third_board.name
        expect_only_tile_headlines_in(@third_board)

        open_board_menu
        click_link @first_board.name
        expect_only_tile_headlines_in(@first_board)
      end

      it "always sends a regular user back to the activity page", js: true do
        visit tiles_path(as: @user)
        open_board_menu
        click_link @second_board.name
        should_be_on activity_path

        visit edit_account_settings_path(as: @user)
        open_board_menu
        click_link @third_board.name
        should_be_on activity_path

        # Including if we're already on the activity page!
        open_board_menu
        click_link @first_board.name
        should_be_on activity_path
      end

      it "sends a client admin back whence they came", js: true do
        BoardMembership.where(user_id: @user.id, demo_id: [@second_board.id, @third_board.id]).each do |membership| 
          membership.is_client_admin = true
          membership.save!
        end

        visit tiles_path(as: @user)
        switch_to_board @second_board
        should_be_on tiles_path

        visit client_admin_users_path
        should_be_on client_admin_users_path
        switch_to_board @third_board
        should_be_on client_admin_users_path

        switch_to_board @first_board
        should_be_on activity_path
      end

      context "mixpanel ping" do
        scenario "as a peon" do
          pending 'Convert to controller spec'
          @user.is_client_admin.should be_false
          @user.is_site_admin.should be_false
          visit activity_path(as: @user)

          switch_to_board @second_board
          crank_dj_clear

          FakeMixpanelTracker.should have_event_matching('Switched Board', user: true, client_admin: false)
        end

        scenario "as a client admin" do
          pending 'Convert to controller spec'
          @user.is_client_admin = true
          @user.save!

          visit activity_path(as: @user)

          switch_to_board @second_board
          crank_dj_clear

          FakeMixpanelTracker.should have_event_matching('Switched Board', user: false, client_admin: true)
        end

        scenario "as a site admin" do
          pending 'Convert to controller spec'
          @user.is_site_admin = true
          @user.save!

          visit activity_path(as: @user)

          switch_to_board @second_board
          crank_dj_clear

          FakeMixpanelTracker.should have_event_matching('Switched Board', user: false, client_admin: true)
        end
      end
    end

    context "when in a single board" do
      it "sees a sensible message in the menu", js: true do
        visit activity_path(as: a_regular_user)
        open_board_menu
        within board_menu_selector do
          page.should have_content("You haven't joined any other boards")
        end
      end
    end
  end
end
