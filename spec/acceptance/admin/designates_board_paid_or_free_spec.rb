require 'acceptance/acceptance_helper'

feature 'Designates board paid or free' do
  def expect_free_board_copy
    page.should have_content("This board is currently free.")
  end

  def expect_paid_board_copy
    page.should have_content("This board is currently paid.")
  end

  def click_make_paid
    click_button "Make board paid"
  end

  def click_make_free
    click_button "Make board free"
  end

  scenario 'in the appropriate place' do
    board = FactoryGirl.create(:demo)

    visit admin_demo_path(board, as: an_admin)
    expect_free_board_copy

    click_make_paid
    expect_paid_board_copy

    click_make_free
    expect_free_board_copy
  end
end
