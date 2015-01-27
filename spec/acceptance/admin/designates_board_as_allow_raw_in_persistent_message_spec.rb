require 'acceptance/acceptance_helper'

feature 'Designates whether or not to allow raw HTML in persistent message for board' do
  scenario 'in the appropriate place' do
    board = FactoryGirl.create(:demo)
    visit admin_demo_path(board, as: an_admin)
    expect_content "No raw HTML allowed in persistent message"

    visit edit_admin_demo_path(board)
    check "Allow raw HTML in persistent message"
    click_button "Update Game"

    visit admin_demo_path(board, as: an_admin)
    expect_content "Raw HTML allowed in persistent message"
  end
end
