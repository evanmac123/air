require 'acceptance/acceptance_helper'

feature 'Has admin privileges on board by board basis' do
  before do
    @client_admin = FactoryGirl.create(:client_admin)
  end

  context 'goes to a board where they are a peon' do
    before do
      @original_board = @client_admin.demo
      @other_board = FactoryGirl.create :demo
      @client_admin.add_board @other_board
      visit client_admin_users_path(as: @client_admin)
      should_be_on client_admin_users_path
    end

    scenario "has no client admin privileges" do
      switch_to_board(@other_board)
      expect_current_board_header(@other_board)
      should_be_on activity_path

      visit client_admin_users_path
      should_be_on activity_path
    end

    scenario "gets them back when switching back to the original board" do
      switch_to_board(@other_board)
      expect_current_board_header(@other_board)
      switch_to_board(@original_board)
      expect_current_board_header(@original_board)

      visit client_admin_users_path
      should_be_on client_admin_users_path
    end

    scenario "loses them yet again when switching back and forth" do
      switch_to_board(@other_board)
      expect_current_board_header(@other_board)
      switch_to_board(@original_board)
      expect_current_board_header(@original_board)
      switch_to_board(@other_board)
      expect_current_board_header(@other_board)

      visit client_admin_users_path
      should_be_on activity_path
    end

    scenario "and back to the original with privileges once more, and then I think we'll call it a day" do
      switch_to_board(@other_board)
      expect_current_board_header(@other_board)
      switch_to_board(@original_board)
      expect_current_board_header(@original_board)
      switch_to_board(@other_board)
      expect_current_board_header(@other_board)
      switch_to_board(@original_board)
      expect_current_board_header(@original_board)

      visit client_admin_users_path
      should_be_on client_admin_users_path
    end
  end
end
