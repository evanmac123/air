require 'acceptance/acceptance_helper'

feature 'Quits free board' do
  include BoardSettingsHelpers

  def last_row_in_board_settings
    rows_in_board_settings.last
  end

  def last_displayed_board_name
    last_row_in_board_settings.find('.board_name').text
  end

  def rows_in_board_settings
    within board_regular_user_controls_selector do
      page.all('.board_wrapper')
    end
  end

  def expect_no_board_name_in_settings(unexpected_name)
    rows_in_board_settings.any? {|row| row.text.include? unexpected_name}.should be_false
  end

  def click_last_delete_link
    within last_row_in_board_settings do
      page.find('.delete_board_icon').click
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

    open_board_settings
    wait_for_board_modal
    expect_no_board_name_in_settings board_to_leave_name
    rows_in_board_settings.should have(2).names
    page.should have_content("OK, you've left the #{board_to_leave_name}")
  end

  it "should have some kind of JS safety on it"
end
