require 'acceptance/acceptance_helper'

feature 'Mutes emails from board management modal' do
  include BoardSettingsHelpers
  include WaitForAjax

  #TODO remove any assertions from these tests taht
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

  def followup_wrapper_selector
    '.followup_wrapper'
  end

  def followup_paddle_selector
    followup_wrapper_selector + ' .green-paddle'
  end

  def selector_for_board(selector, board)
    selector + "[data-board-id='#{board.id}']"
  end

  def click_first_digest_mute
    page.first(digest_mute_selector, visible: false).click
  end

  def click_first_digest_unmute
    page.first(digest_unmute_selector, visible: false).click
  end

  def click_first_followup_mute
    page.first(followup_mute_selector, visible:false).click
  end

  def click_first_followup_unmute
    page.first(followup_unmute_selector, visible:false).click
  end

  def click_digest_mute_for_board(board)
    page.first(selector_for_board(digest_mute_selector, board), visible: false).click
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
    page.first(digest_mute_selector, visible: false)['checked'].should be_true
    page.first(digest_unmute_selector, visible:false)['checked'].should_not be_true
  end

  def expect_first_followup_slider_in_mute_position
    page.first(followup_mute_selector, visible:false)['checked'].should be_true
    page.first(followup_unmute_selector, visible:false)['checked'].should_not be_true
  end

  def expect_last_followup_slider_in_unmute_position
    page.all(followup_mute_selector)[-1]['checked'].should_not be_true
    page.all(followup_unmute_selector)[-1]['checked'].should be_true
  end

  def expect_followup_slider_in_mute_position_for_board(board)
    page.first((selector_for_board followup_mute_selector, board), visible: false)['checked'].should be_true
    page.first(selector_for_board(followup_unmute_selector, board), visible:false)['checked'].should be_false
  end

  def expect_followup_slider_in_unmute_position_for_board(board)
    page.first(selector_for_board(followup_mute_selector, board), visible:false)['checked'].should be_false
    page.first((selector_for_board followup_unmute_selector, board), visible: false)['checked'].should be_true
  end

  def followup_input_selectors
    [followup_mute_selector, followup_unmute_selector]  
  end

  def followup_presentation_selectors
    [followup_wrapper_selector, followup_paddle_selector]  
  end

  def expect_first_followup_slider_not_disabled
    followup_input_selectors.each do |input_selector|
      page.first(input_selector, visible: false)['disabled'].should_not be_present
    end

    followup_presentation_selectors.each do |presentation_selector|
      page.first(presentation_selector + '.disabled').should_not be_present
    end
  end

  def expect_first_followup_slider_disabled
    followup_input_selectors.each do |input_selector|
      page.first(input_selector, visible: false)['disabled'].should be_present
    end

    followup_presentation_selectors.each do |presentation_selector|
      page.first(presentation_selector + '.disabled').should be_present
    end
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

  scenario 'muting/unmuting original disables/enables followup slider when slider starts enabled', js: true do
    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal

    expect_first_followup_slider_not_disabled

    click_first_digest_mute
    wait_for_ajax
    expect_first_followup_slider_disabled

    click_first_digest_unmute
    wait_for_ajax
    expect_first_followup_slider_not_disabled
  end

  scenario 'muting/unmuting original disables/enables followup slider when slider starts disabled', js: true do
    board_membership_for_board(user, user.demo).update_attributes(digest_muted: true, followup_muted: true)
    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal

    expect_first_followup_slider_disabled

    click_first_digest_unmute
    wait_for_ajax
    expect_first_followup_slider_not_disabled

    click_first_digest_mute
    wait_for_ajax
    expect_first_followup_slider_disabled
  end

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
