require 'acceptance/acceptance_helper'

feature 'Site admin sets new version of email template' do
  scenario 'on a board in site-admin' do
    email_version = 2
    board = FactoryBot.create(:demo)
    visit edit_admin_demo_path(board, as: an_admin)

    fill_in 'demo[email_version]', with: email_version
    click_button "Save"

    expect(board.reload.email_version).to eq(email_version)
  end
end
