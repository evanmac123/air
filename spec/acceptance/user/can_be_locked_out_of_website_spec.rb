require 'acceptance/acceptance_helper'

feature 'Can be locked out of website' do
  let(:demo) { FactoryGirl.create(:demo, website_locked: true) }
  let(:user) { FactoryGirl.create(:user, :claimed, :with_phone_number, demo: demo) }

  def lockout_copy
    "We're sorry, your organization is not using the H.Engage website. We'll let you know if your organization begins using the website again."
  end

  scenario 'on an instance by instance basis' do
    has_password(user, "foobar")

    signin_as user, "foobar"

    expect_content lockout_copy
  end

  scenario 'but can still text in' do
    mo_sms user.phone_number, 'myid'
    expect_mt_sms_including user.phone_number, user.sms_slug
  end

  scenario 'but can breeze right past that as a site admin' do
    has_password(user, "foobar")
    user.is_site_admin = true
    user.save!

    signin_as user, "foobar"
    expect_no_content lockout_copy
  end

  scenario "but can still change their settings" do
    has_password(user, "foobar")
    signin_as user, "foobar"

    visit edit_account_settings_path
    choose "Both"
    page.find("#save-notification-settings").click

    should_be_on edit_account_settings_path
    page.find('*[@name="user[notification_method]"][@checked]')['value'].should == 'both'
  end

  scenario "and doesn't get the welcome or followup email on claiming account" do
    demo.update_attributes(phone_number: "+19085551212")
    new_user = FactoryGirl.create(:user, demo: demo, claim_code: 'somedude')

    mo_sms "+14155551212", "somedude", demo.phone_number
    crank_dj_clear

    ActionMailer::Base.deliveries.should be_empty
  end
end
