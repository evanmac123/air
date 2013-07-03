require 'acceptance/acceptance_helper'

feature 'Can be locked out of website' do
  let(:demo) { FactoryGirl.create(:demo, website_locked: true) }
  let(:user) { FactoryGirl.create(:user, :claimed, :with_phone_number, demo: demo) }

  def lockout_copy
    "This instance is currently locked out of the website"
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
end
