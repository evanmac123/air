require 'acceptance/acceptance_helper'
metal_testing_hack(SmsController)

feature 'User gets no friend requests by sms' do
  scenario 'even when their notification settings allow it' do
    user1 = FactoryGirl.create(:user, :claimed, :with_phone_number, notification_method: 'both')
    user2 = FactoryGirl.create(:user, :claimed, :with_phone_number, notification_method: 'sms')

    demo1 = user1.demo
    demo2 = user2.demo
    demo1.update_attributes(phone_number: "+16179990123")
    demo2.update_attributes(phone_number: "+16179991234")

    friendly1 = FactoryGirl.create(:user, :claimed, :with_phone_number, demo: demo1)
    friendly2 = FactoryGirl.create(:user, :claimed, :with_phone_number, demo: demo2)

    mo_sms(friendly1.phone_number, "follow #{user1.sms_slug}")
    mo_sms(friendly2.phone_number, "follow #{user2.sms_slug}")

    crank_dj_clear

    expect_no_mt_sms(user1.phone_number)
    expect_no_mt_sms(user2.phone_number)
  end
end
