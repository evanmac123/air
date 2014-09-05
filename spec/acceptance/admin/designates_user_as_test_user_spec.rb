require 'acceptance/acceptance_helper'

feature 'Admin designates user as test (or not)' do
  scenario "making a non-test user a test user" do
    user = FactoryGirl.create(:user)
    user.is_test_user.should be_false

    visit edit_admin_demo_user_path(user.demo, user, as: an_admin)
    click_button "Make test user"
    page.should have_content("OK, this user is now marked as a test user.")
    user.reload.is_test_user.should be_true
  end

  scenario "making a test user a non-test user" do
    user = FactoryGirl.create(:user, is_test_user: true)

    visit edit_admin_demo_user_path(user.demo, user, as: an_admin)
    click_button "Make non-test user"
    page.should have_content("OK, this user is now marked as not a test user.")
    user.reload.is_test_user.should be_false
  end
end
