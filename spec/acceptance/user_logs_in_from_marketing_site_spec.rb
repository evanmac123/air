require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Requests Rules"do
  scenario "User requests rules" do
    @email = 'mine@yours.com'
    @password = 'fooyoobar'
    FactoryGirl.create :user, :phone_number => "+14155551212", password: @password, email: @email

    visit root_path
    fill_in 'session_email', :with => @email
    fill_in 'session_password', :with => @password
    click_button 'sign_in_button'
    page.should have_content("Welcome back")
  end
end
