require 'acceptance/acceptance_helper'

feature 'Manages board settings' do
  def open_board_settings
    page.find('#board_settings_toggle').click
  end

  def board_admin_controls_selector
    "#admin_controls"
  end

  def wait_for_board_modal
    page.should have_content("Board Settings")
  end

  context "when they admin no boards" do
    it "should not display the admin controls"
  end

  context "when they admin at least one board" do
    it "should show admin controls for each such board", js: true do
      user = FactoryGirl.create(:user)
      boards = [user.demo, FactoryGirl.create(:demo)]

      boards.each do |board|
        user.add_board(board)
        user.move_to_new_demo(board)
        user.is_client_admin = true
        user.displayed_activity_page_admin_guide = true
        user.save!
      end

      visit activity_path(as: user)
      open_board_settings
      wait_for_board_modal
      boards.each do |board|
        within(board_admin_controls_selector) do
          page.should have_content(board.name)
        end
      end
    end

    it "should truncate long board names"
  end
end
