require 'acceptance/acceptance_helper'

feature 'Admin edits users' do
  scenario "by making one a client admin" do
    regular_schmuck = FactoryGirl.create(:user)
    expect(regular_schmuck.is_client_admin).to be_falsey

    visit edit_admin_demo_user_path(regular_schmuck.demo, regular_schmuck, as: an_admin)
    check 'Is client admin:'
    click_button 'Update User'
    expect(regular_schmuck.reload.is_client_admin).to be_truthy

    visit edit_admin_demo_user_path(regular_schmuck.demo, regular_schmuck)
    uncheck 'Is client admin:'
    click_button 'Update User'
    expect(regular_schmuck.reload.is_client_admin).to be_falsey
  end
end
