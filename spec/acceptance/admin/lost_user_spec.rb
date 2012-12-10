require 'acceptance/acceptance_helper'

feature "Find a lost user" do
  before(:each) do
    @admin = FactoryGirl.create(:site_admin, password: 'oooooo')
    @lost_email = 'lost@frost.net'
    @lost_personal = 'more_lost@frost.net'
    @lost = FactoryGirl.create(:user, email: @lost_personal, overflow_email: @lost_email)
    FactoryGirl.create(:user, name: 'Someone Else')
    signin_as(@admin, 'oooooo')
  end

  it "should take me to the lost user" do
    # Using email
    visit admin_path
    fill_in 'user_email', :with => @lost_email
    click_button 'Find'
    current_path.should == edit_admin_demo_user_path(@lost.demo, @lost)

    # Using personal email
    visit admin_path
    fill_in 'user_email', :with => @lost_personal
    click_button 'Find'
    current_path.should == edit_admin_demo_user_path(@lost.demo, @lost)

    # Using a nonexistent email
    visit admin_path
    fill_in 'user_email', :with => 'nonsense'
    click_button 'Find'
    current_path.should == admin_path
    page.should have_content "Could not find user with email 'nonsense'"
  end
end
