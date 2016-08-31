require 'acceptance/acceptance_helper'

feature 'Designates board paid or free' do
  scenario 'in the appropriate place' do
    board = FactoryGirl.create(:demo)
    user = an_admin
    visit admin_demo_path(board, as: user)

    click_link "Make board paid"
    click_link "Make board free"
  end
end
