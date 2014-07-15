require 'acceptance/acceptance_helper'

feature 'Quits free board' do
  include BoardSettingsHelpers
  def last_displayed_board_name
    last_row_in_board_settings.find('.board_name').text
  end

  def expect_no_board_name_in_settings(unexpected_name)
    rows_in_board_settings.any? {|row| row.text.include? unexpected_name}.should be_false
  end

  def expect_safety_submit_disabled
    within(safety_modal_selector) do
      page.find('input[type="submit"]')['disabled'].should be_present
    end
  end

  def expect_safety_submit_enabled
    within(safety_modal_selector) do
      page.find('input[type="submit"]')['disabled'].should_not be_present
    end
  end

  scenario "by clicking on the delete link in board management", js: true do
    user = FactoryGirl.create(:user)
    2.times {user.add_board FactoryGirl.create(:demo)}
    visit activity_path(as: user)

    open_board_settings
    wait_for_board_modal
    board_to_leave_name = last_displayed_board_name
    click_last_delete_link
    complete_safety_modal

    open_board_settings
    wait_for_board_modal
    expect_no_board_name_in_settings board_to_leave_name
    rows_in_board_settings.should have(2).names
    page.should have_content("OK, you've left the #{board_to_leave_name}")
  end

  context "the safety modal" do
    it "should be disabled until the text field within contains the exact right text", js: true do
      user = FactoryGirl.create(:user)
      visit activity_path(as: user)
      open_board_settings
      wait_for_board_modal

      click_last_delete_link
      wait_for_safety_modal
      expect_safety_submit_disabled

      fill_in_safety_text_field 'D'
      expect_safety_submit_disabled

      fill_in_safety_text_field 'DELET'
      expect_safety_submit_disabled

      fill_in_safety_text_field 'DELETE'
      expect_safety_submit_enabled
    end
  end
end
