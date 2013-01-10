require 'acceptance/acceptance_helper'

feature 'Admin edits users' do
  scenario "by making one a client admin" do
    regular_schmuck = FactoryGirl.create(:user)
    regular_schmuck.is_client_admin.should be_false

    visit edit_admin_demo_user_path(regular_schmuck.demo, regular_schmuck, as: an_admin)
    check 'Is client admin:'
    click_button 'Update User'
    regular_schmuck.reload.is_client_admin.should be_true

    visit edit_admin_demo_user_path(regular_schmuck.demo, regular_schmuck)
    uncheck 'Is client admin:'
    click_button 'Update User'
    regular_schmuck.reload.is_client_admin.should be_false
  end
end
