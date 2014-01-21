require 'acceptance/acceptance_helper'

feature 'Ungates public board feature' do

  scenario 'by clicking a button' do
    board = FactoryGirl.create(:demo)
    $rollout.active?(:public_board, board).should be_false

    visit admin_demo_path(board, as: an_admin)
    click_link "Gate/ungate features"

    click_button "Activate public board"
    $rollout.active?(:public_board, board).should be_true
    expect_content "Public board activated"

    click_button "Deactivate public board"
    $rollout.active?(:public_board, board).should be_false
    expect_content "Public board deactivated"
  end

end
