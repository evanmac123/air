require 'acceptance/acceptance_helper'

feature 'Manages board settings' do
  def open_board_settings
    page.find('#board_settings_toggle').click
    wait_for_board_modal
  end

  def board_admin_controls_selector
    "#admin_board_controls"
  end

  def board_regular_user_controls_selector
    "#user_board_controls"
  end

  def wait_for_board_modal
    page.should have_content("Board Settings")
  end

  def long_board_name
    "36 characters should be just about enough for anybody don't you think?"  
  end

  def truncated_long_board_name
    "36 characters should be just abou..."  
  end

  context "when they admin no boards" do
    before do
      @user = FactoryGirl.create(:user)
      @user.boards_as_admin.should be_empty
      @boards = [@user.demo, FactoryGirl.create(:demo)]
      @user.add_board(@boards.last)
    end

    it "should not display the admin controls", js: true do
      visit activity_path(as: @user)
      open_board_settings
      page.should have_no_css(board_admin_controls_selector)
    end

    it "should show all boards they are a regular user in, in the appropriate section", js: true do
      visit activity_path(as: @user)
      open_board_settings
      within(board_regular_user_controls_selector) do
        @boards.each do |board|
          expect_content board.name
        end
      end
    end

    it "should truncate long board names", js: true do
      @boards.last.update_attributes(name: long_board_name)
      visit activity_path(as: @user)
      open_board_settings
      within(board_regular_user_controls_selector) do
        expect_content truncated_long_board_name
      end
    end
  end

  context "when they admin at least one board" do
    before do
      @user = FactoryGirl.create(:user)
      @boards = [@user.demo, FactoryGirl.create(:demo)]

      @boards.each do |board|
        @user.add_board(board)
        @user.move_to_new_demo(board)
        @user.is_client_admin = true
        @user.save!
      end
    end

    it "should show admin controls for each such board", js: true do
      visit activity_path(as: @user)
      open_board_settings
      @boards.each do |board|
        within(board_admin_controls_selector) do
          page.should have_content(board.name)
        end
      end
    end

    it "should truncate long board names", js: true do
      @boards.last.update_attributes(name: long_board_name)
      visit activity_path(as: @user)
      open_board_settings

      within(board_admin_controls_selector) do
        page.should have_content truncated_long_board_name
      end
    end
  end

  context "when they are an admin in some boards and a peon in others" do
    before do
      @user = FactoryGirl.create(:user)
      @user.add_board(FactoryGirl.create(:demo))

      @boards_as_admin = FactoryGirl.create_list(:demo, 2)
      @boards_as_admin.each do |board|
        @user.add_board(board)
        @user.board_memberships.find_by_demo_id(board.id).update_attributes(is_client_admin: true)
      end

      # And let's just sanity check that these two methods do in fact partition
      # boards like we want.
      @user.boards_as_regular_user.should have(2).board
      @user.boards_as_admin.should have(2).board

      all_boards = @user.boards_as_regular_user + @user.boards_as_admin
      all_boards.should have(4).boards
      all_boards.map(&:id).uniq.should have(4).ids
    end

    it "should show each board, once, in the correct section", js: true do
      visit activity_path(as: @user)
      open_board_settings

      within(board_admin_controls_selector) do
        @user.boards_as_admin.each do |board|
          page.should have_content board.name
        end
      end

      within(board_regular_user_controls_selector) do
        @user.boards_as_regular_user.each do |board|
          page.should have_content board.name
        end
      end
    end

    it "should have a divider between the sections"
  end
end
