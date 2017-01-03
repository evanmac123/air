require 'acceptance/acceptance_helper'

feature "Find a lost user" do
  before(:each) do
    @lost_email = 'lost@frost.net'
    @lost_personal = 'more_lost@frost.net'
    @lost = FactoryGirl.create(:user, email: @lost_personal, overflow_email: @lost_email)
    FactoryGirl.create(:user, name: 'Someone Else')
  end

  it "should take me to the lost user" do
    # Using email
    visit admin_path(as: an_admin)
    fill_in 'user_email', :with => @lost_email
    click_button 'Find'
    expect(current_path).to eq(edit_admin_demo_user_path(@lost.demo, @lost))

    # Using personal email
    visit admin_path(as: an_admin)
    fill_in 'user_email', :with => @lost_personal
    click_button 'Find'
    expect(current_path).to eq(edit_admin_demo_user_path(@lost.demo, @lost))

    # Using a nonexistent email
    visit admin_path(as: an_admin)
    fill_in 'user_email', :with => 'nonsense'
    click_button 'Find'
    expect(current_path).to eq(admin_path)
    expect(page).to have_content "Could not find user with email 'nonsense'"
  end
end
