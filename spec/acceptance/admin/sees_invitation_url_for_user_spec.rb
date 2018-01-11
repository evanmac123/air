require 'acceptance/acceptance_helper'

feature 'Admin sees invitation url for user' do
  scenario 'in client admin user page' do
    user = FactoryBot.create(:user)
    visit admin_demo_users_path(user.demo, as: an_admin)
    expect_content invitation_url(user.invitation_code)
  end
end
