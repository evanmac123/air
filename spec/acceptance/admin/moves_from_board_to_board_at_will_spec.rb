require 'acceptance/acceptance_helper'

feature 'Site admin' do
  scenario 'moves from board to board at will', js: true do
    first_board, second_board, third_board = FactoryGirl.create_list(:demo, 3)
    admin = FactoryGirl.create(:site_admin)
    admin.demos.should have(1).demo
    visit activity_path(as: admin)

    switch_to_board first_board
    page.should have_content "CURRENT BOARD #{first_board.name}"

    switch_to_board second_board
    page.should have_content "CURRENT BOARD #{second_board.name}"

    switch_to_board third_board
    page.should have_content "CURRENT BOARD #{third_board.name}"

    admin.demos.reload.should have(4).demos
    admin.demos.pluck(:name).sort.should == Demo.pluck(:name).sort
    admin.reload.demo.should == third_board
  end
end
