require 'acceptance/acceptance_helper'

feature 'Designates board paid or free' do
  def click_make_paid
    click_button "Make board paid"
  end

  def click_make_free
    click_button "Make board free"
  end

  scenario 'in the appropriate place' do
    board = FactoryGirl.create(:demo)
    user = an_admin
    visit admin_demo_path(board, as: user)

    click_make_paid
    expect_ping 'Board Type', {type: "Paid"}, user

    click_make_free
    expect_ping 'Board Type', {type: "Free"}, user
  end
end
