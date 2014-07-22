require 'acceptance/acceptance_helper'

feature 'Mutes emails from board management modal' do
  include BoardSettingsHelpers
  include WaitForAjax

  let(:user) {FactoryGirl.create(:user)}

  def followup_off_selector
    '.followup_off'
  end

  def click_first_followup_off
    page.first(followup_off_selector).click
  end

  def expect_followup_muted(user, board)
    user.board_memberships.find_by_demo_id(board.id).followup_muted.should be_true
  end

  scenario 'mutes followup with a slider', js: true do
    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal

    click_first_followup_off
    wait_for_ajax
    expect_followup_muted(user, user.demo)
  end

  scenario 'starts with the sliders in the appropriate state'
  scenario 'mutes both original and followup with a slider'
  scenario 'unmutes followup with a slider'
  scenario 'unmutes original with a slider'

  scenario 'mutes are on a board-by-board basis'
  scenario 'digest mutes are actually respected when we send emails'
end
