require 'acceptance/acceptance_helper'

feature 'Designates board paid or free', js: true do
  def click_make_paid
    click_link "Make board paid"
  end

  def click_make_free
    click_link "Make board free"
  end

  scenario 'in the appropriate place' do
    board = FactoryGirl.create(:demo)
    user = an_admin

    visit admin_demo_path(board, as: user)

    click_make_paid
    expect(page).to have_link "Make board free"
    click_make_free
    expect(page).to have_link "Make board paid"
  end
end
