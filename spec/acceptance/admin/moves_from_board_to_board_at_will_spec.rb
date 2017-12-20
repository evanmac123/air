require 'acceptance/acceptance_helper'

feature 'Site admin' do
  scenario 'moves from board to board at will', js: true do
    first_board, second_board = FactoryBot.create_list(:demo, 2)
    admin = FactoryBot.create(:site_admin)
    expect(admin.demos.size).to eq(1)
    visit activity_path(as: admin)

    switch_to_board(first_board)
    expect_content "Current Board #{first_board.name}"

    switch_to_board(second_board)
    expect_content "Current Board #{second_board.name}"
  end
end
