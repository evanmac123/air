require 'acceptance/acceptance_helper'

feature 'Mutes emails from board management modal' do
  include BoardSettingsHelpers
  include WaitForAjax

  let(:user) {FactoryGirl.create(:user)}

  def digest_mute_selector
    '.digest_mute'
  end

  def digest_unmute_selector
    '.digest_unmute'
  end

  def followup_mute_selector
    '.followup_mute'
  end

  def followup_unmute_selector
    '.followup_unmute'
  end

  def click_first_digest_mute
    page.first(digest_mute_selector).click
  end

  def click_first_digest_unmute
    page.first(digest_unmute_selector).click
  end

  def click_first_followup_mute
    page.first(followup_mute_selector).click
  end

  def click_first_followup_unmute
    page.first(followup_unmute_selector).click
  end

  def board_membership_for_board(user, board)
    user.board_memberships.find_by_demo_id(board.id)  
  end

  def expect_digest_muted(user, board)
    board_membership_for_board(user, board).digest_muted.should be_true
  end

  def expect_digest_unmuted(user, board)
    board_membership_for_board(user, board).digest_muted.should be_false
  end

  def expect_followup_muted(user, board)
    board_membership_for_board(user, board).followup_muted.should be_true
  end

  def expect_followup_unmuted(user, board)
    board_membership_for_board(user, board).followup_muted.should be_false
  end

  def expect_digest_slider_in_mute_position
    page.first(digest_mute_selector)['checked'].should be_true
    page.first(digest_unmute_selector)['checked'].should_not be_true
  end

  def expect_followup_slider_in_mute_position
    page.first(followup_mute_selector)['checked'].should be_true
    page.first(followup_unmute_selector)['checked'].should_not be_true
  end

  scenario 'mutes followup with a slider', js: true do
    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal

    click_first_followup_mute
    wait_for_ajax
    expect_followup_muted(user, user.demo)
  end

  scenario 'unmutes followup with a slider', js: true do
    user.board_memberships.first.update_attributes(followup_muted: true)
    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal
    expect_followup_slider_in_mute_position

    click_first_followup_unmute
    wait_for_ajax
    expect_followup_unmuted(user, user.demo)
  end

  scenario 'mutes both original and followup with a slider', js: true do
    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal

    click_first_digest_mute
    wait_for_ajax

    expect_digest_slider_in_mute_position
    expect_followup_slider_in_mute_position
    expect_digest_muted(user, user.demo)
    expect_followup_muted(user, user.demo)
  end

  scenario 'muting original disables followup slider'

  scenario 'unmuting original re-enables followup slider'

  scenario 'unmutes original with a slider', js: true do
    user.board_memberships.first.update_attributes(digest_muted: true)
    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal
    expect_digest_slider_in_mute_position

    click_first_digest_unmute
    wait_for_ajax
    expect_digest_unmuted(user, user.demo)
  end
end
