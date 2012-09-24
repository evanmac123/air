require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Accepts Invitation" do

  before(:each) do
    Demo.find_each { |f| f.destroy }
    @user = FactoryGirl.create :user
    visit invitation_page(@user)
    fill_in 'user_password', :with => 'foobar'
    fill_in 'user_password_confirmation', :with => 'foobar'
    page.find('#notification_prefs').should_not be_visible
    fill_in 'user_new_phone_number', :with => '2223334444'
    page.find('#notification_prefs').should be_visible
    check 'user_terms_and_conditions'
  end

  it "sets contact prefs to 'email'", js: true do
    choose 'Email'
    user = @user
    click_button 'Log in'
    sleep(5)
    wait_until { @user.reload.accepted_invitation_at }
    @user.reload.notification_method.should == 'email'
  end

  it "sets contact prefs to 'sms'", js: true do
    choose 'SMS/text message'
    click_button 'Log in'
    sleep(5)
    wait_until { @user.reload.accepted_invitation_at }
    @user.notification_method.should == 'sms'
  end

  it "sets contact prefs to 'both'", js: true do
    choose 'Both'
    click_button 'Log in'
    sleep(5)
    wait_until { @user.reload.accepted_invitation_at }
    @user.notification_method.should == 'both'
  end
end

