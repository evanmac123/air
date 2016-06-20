require 'acceptance/acceptance_helper'

feature 'Manages board settings' do
  include BoardSettingsHelpers
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
          expect_content board.name.upcase
        end
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
          expect_content(board.name.upcase)
        end
      end
    end

    it "should let them edit a board name by clicking the name", js: true do
      visit activity_path(as: @user)
      open_board_settings

      board_to_change = @boards.first
      fill_in_new_board_name(board_to_change, "Hapsburg Dynasty")
      click_save_link

      expect_content("Saved!")
    end

    it "should give helpful feedback if the board name is bad", js: true do
      FactoryGirl.create(:demo, name: "Nuclear Lemmings Board")

      visit activity_path(as: @user)
      open_board_settings

      board_to_change = @boards.first
      fill_in_new_board_name(board_to_change, "Nuclear Lemmings")
      click_save_link

      expect_content "Sorry, that board name is already taken."
    end

    it "updates the board name in the board switcher", js: true do
      visit activity_path(as: @user)
      open_board_settings
      new_name = "this be the new name"
      board_to_change = @boards.first
      original_board_name = board_to_change.name

      fill_in_new_board_name(board_to_change,new_name)
      click_save_link
      page.should have_no_content(original_board_name)
      expect_content new_name
    end

    it "updates the name of the current board (respecting trunaction) in the switcher if it's changed", js: true do
      visit activity_path(as: @user)
      open_board_settings

      fill_in_new_board_name(@user.demo, "A Name That Certainly Is Long Enough To Exercise Truncation")
      click_save_link

      within "#board_switch #current_board_name" do
        expect_content "A Name That ..."
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
          expect_content board.name.upcase
        end
      end

      within(board_regular_user_controls_selector) do
        @user.boards_as_regular_user.each do |board|
          expect_content board.name.upcase
        end
      end
    end
  end

  def board_admin_controls_selector
    "#admin_board_controls"
  end

  def selector_for_board(board)
    "#admin_board_controls .board_name[data-demo_id=\"#{board.id}\"]"  
  end

  def fill_in_new_board_name(board, new_name)
    # Stole this from fill_in_image_credit. If we're gonna do a lot with
    # contenteditable, we should factor this out.

    js_to_fake_edit = "$('#{selector_for_board(board)}').focus().keydown().html('#{new_name}').keyup()"
    page.execute_script(js_to_fake_edit)
  end

  def click_save_link
    within(board_admin_controls_selector) { page.find('a', text: 'Save', visible: true).click }
  end


end
