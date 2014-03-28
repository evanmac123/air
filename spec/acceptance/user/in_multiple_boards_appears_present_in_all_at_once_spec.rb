require 'acceptance/acceptance_helper'

feature 'In multiple boards appears present in all at once' do
  USER_NAME = "Mister Multiple"

  before do
    @first_board = FactoryGirl.create(:demo, :activated)
    @second_board = FactoryGirl.create(:demo, :activated)

    @user = FactoryGirl.create(:user, name: USER_NAME, demo: @first_board)
    @user.add_board(@second_board)

    @user.demos.should have(2).demos
    @user.demo.should == @first_board

    @first_admin = FactoryGirl.create(:client_admin, demo: @first_board)
    @second_admin = FactoryGirl.create(:client_admin, demo: @second_board)
  end

  scenario 'appears in client admin search results for all demos', js: true do
    visit client_admin_users_path(as: @first_admin)
    click_link "Show everyone"
    page.should have_content(USER_NAME)

    visit client_admin_users_path(as: @second_admin)
    click_link "Show everyone"
    page.should have_content(USER_NAME)
  end

  scenario 'appears in site admin search results for all demos' do
    visit admin_demo_path(@first_board, as: an_admin)
    click_link "Everyone"
    page.should have_content(USER_NAME)
    visit admin_demo_path(@second_board, as: an_admin)
    click_link "Everyone"
    page.should have_content(USER_NAME)
  end
end
