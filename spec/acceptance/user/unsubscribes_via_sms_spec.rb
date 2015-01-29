require 'acceptance/acceptance_helper'

feature "User texts 'stop' to set notification preferences" do
  # Note this is also tested in more detail in 
  # spec/models/special_command_handlers/stop_hander_spec.rb

  before(:each) do
    @juan_phone = "+12084663723"
    @juan = FactoryGirl.create(:user_with_phone, phone_number: @juan_phone)
    @juan.notification_method.should == 'both'
  end

  scenario "Juan texts 'stop' and receives a confirmation"  do
    mo_sms(@juan_phone, 'sToP ')
    crank_dj_clear 
    expected = "Ok, you won't receive any more texts from us. To change your contact preferences, log into www.airbo.com and click Settings, or email support@airbo.com."

    expect_mt_sms(@juan_phone, expected)
    @juan.reload.notification_method.should == 'email'
  end

end
