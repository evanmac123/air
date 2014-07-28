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

  def selector_for_board(selector, board)
    selector + "[data-board_id='#{board.id}']"
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

  def click_digest_mute_for_board(board)
    page.first(selector_for_board digest_mute_selector, board).click
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

  def expect_first_digest_slider_in_mute_position
    page.first(digest_mute_selector)['checked'].should be_true
    page.first(digest_unmute_selector)['checked'].should_not be_true
  end

  def expect_first_followup_slider_in_mute_position
    page.first(followup_mute_selector)['checked'].should be_true
    page.first(followup_unmute_selector)['checked'].should_not be_true
  end

  def expect_last_followup_slider_in_unmute_position
    page.all(followup_mute_selector)[-1]['checked'].should_not be_true
    page.all(followup_unmute_selector)[-1]['checked'].should be_true
  end

  def expect_followup_slider_in_mute_position_for_board(board)
    page.first(selector_for_board followup_mute_selector, board)['checked'].should be_true
    page.first(selector_for_board followup_unmute_selector, board)['checked'].should be_false
  end

  def expect_followup_slider_in_unmute_position_for_board(board)
    page.first(selector_for_board followup_mute_selector, board)['checked'].should be_false
    page.first(selector_for_board followup_unmute_selector, board)['checked'].should be_true
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
    expect_first_followup_slider_in_mute_position

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

    expect_first_digest_slider_in_mute_position
    expect_first_followup_slider_in_mute_position
    expect_digest_muted(user, user.demo)
    expect_followup_muted(user, user.demo)
  end

  scenario 'muting original mutes followup for that same board only', js: true do
    new_board = FactoryGirl.create(:demo)
    user.add_board(new_board)

    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal
    click_digest_mute_for_board(user.demo)
    wait_for_ajax

    expect_followup_slider_in_mute_position_for_board(user.demo)
    expect_followup_slider_in_unmute_position_for_board(new_board)
    expect_followup_unmuted(user, new_board)
  end

  scenario 'muting original disables followup slider'

  scenario 'unmuting original re-enables followup slider'

  scenario 'unmutes original with a slider', js: true do
    user.board_memberships.first.update_attributes(digest_muted: true)
    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal
    expect_first_digest_slider_in_mute_position

    click_first_digest_unmute
    wait_for_ajax
    expect_digest_unmuted(user, user.demo)
  end
end
