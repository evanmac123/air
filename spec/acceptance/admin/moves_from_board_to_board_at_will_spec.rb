require 'acceptance/acceptance_helper'

feature 'Site admin' do
  scenario 'moves from board to board at will', js: true do
    first_board, second_board = FactoryGirl.create_list(:demo, 2)
    admin = FactoryGirl.create(:site_admin)
    admin.demos.should have(1).demo
    visit activity_path(as: admin)

    switch_to_board(first_board)
    expect_content "Current Board #{first_board.name}"

    switch_to_board(second_board)
    expect_content "Current Board #{second_board.name}"

    admin.demos.reload.should have(3).demos
  end
end
