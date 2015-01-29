require 'acceptance/acceptance_helper'

metal_testing_hack SmsController

feature 'User requests support' do
  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_phone_number)
    @user = FactoryGirl.create(:user, :with_phone_number, demo: @demo)
  end

  scenario 'and gets response about when they can expect help' do
    mo_sms(@user.phone_number, 'support', @demo.phone_number)
    expect_mt_sms @user.phone_number, "Got it. We'll have someone email you shortly. Tech support is open 9 AM to 6 PM ET. If it's outside those hours, we'll follow-up first thing when we open."
  end

  context "when the demo has a custom support reply" do
    before(:each) do
      @demo.update_attributes(custom_support_reply: "Got it, chief.")
    end

    scenario "the user should get that reply to the request for support" do
      mo_sms(@user.phone_number, 'support', @demo.phone_number)
      expect_mt_sms @user.phone_number, "Got it, chief."
    end
  end

  scenario "which causes an email to get set to the admins" do
    mo_sms(@user.phone_number, "test 1", @demo.phone_number)
    mo_sms(@user.phone_number, "test 2", @demo.phone_number)
    mo_sms(@user.phone_number, "test 3", @demo.phone_number)
    mo_sms(@user.phone_number, 'support', @demo.phone_number)

    crank_dj_clear

    open_email('support@airbo.com')
    current_email.to_s.should include("Support requested by #{@user.name} of #{@demo.name} (#{@user.email}, #{@user.phone_number}")
    current_email.to_s.gsub(/\s+/m, " ").should include("test 3 test 2 test 1")
  end
end
