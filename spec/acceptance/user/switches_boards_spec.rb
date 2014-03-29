require 'acceptance/acceptance_helper'

feature 'Switches boards' do
  def expect_current_board_header(board)
    page.should have_content("Current board #{board.name}")
  end

  context "via the desktop menu" do
    context "when in multiple boards" do
      before do
        @user = FactoryGirl.create(:user)
        @first_board = @user.demo

        @second_board = FactoryGirl.create(:demo)
        @user.add_board(@second_board)

        visit activity_path(as: @user)
      end

      it "shows the name of the current board" do
        expect_current_board_header(@first_board)
      end

      it "shows all non-current boards in the switch menu"

      it "allows switching between them" do
        pending
        open_board_menu
      end
    end

    context "when in a single board" do
      it "sees a sensible message in the menu"
    end
  end
end
