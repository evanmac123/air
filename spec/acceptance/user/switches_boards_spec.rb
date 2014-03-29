require 'acceptance/acceptance_helper'

feature 'Switches boards' do
  def expect_current_board_header(board)
    page.should have_content("Current board #{board.name}")
  end

  def open_board_menu
    page.find('#board_switch_toggler').click
  end

  def board_menu_selector
    '.other_boards'  
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

      it "allows switching between them"    
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
