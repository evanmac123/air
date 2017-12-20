require 'acceptance/acceptance_helper'

feature 'Admin edits users' do
  scenario "by making one a client admin" do
    regular_schmuck = FactoryBot.create(:user)
    expect(regular_schmuck.is_client_admin).to be_falsey

    visit edit_admin_demo_user_path(regular_schmuck.demo, regular_schmuck, as: an_admin)

    fill_in 'Name', with: "Airbo Robot"
    check 'Is client admin'

    click_button 'Update User'

    updated_user = User.find(regular_schmuck.id)
    expect(updated_user.is_client_admin).to be true
    expect(updated_user.name).to eq("Airbo Robot")
  end
end
