require 'acceptance/acceptance_helper'

feature 'Admin sees invitation url for user' do
  scenario 'in client admin user page' do
    user = FactoryGirl.create(:user)
    p user.demo
    p an_admin
    visit admin_demo_users_path(user.demo, as: an_admin)
    expect_content invitation_url(user.invitation_code)
  end
end
