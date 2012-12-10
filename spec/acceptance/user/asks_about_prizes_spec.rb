require 'acceptance/acceptance_helper'

feature 'User asks about prizes' do
  scenario "Demo has prizes" do
    demo = FactoryGirl.create(:demo, prize: "Ninety-nine bottles of beer on the wall.")
    user = FactoryGirl.create(:user_with_phone, demo: demo)

    mo_sms(user.phone_number, "prizes")
    expect_mt_sms(user.phone_number, "Ninety-nine bottles of beer on the wall.")
  end

  scenario "Demo has no prizes" do
    user = FactoryGirl.create(:user_with_phone)

    mo_sms(user.phone_number, "prizes")
    expect_mt_sms(user.phone_number, "Sorry, no physical prizes this time. This one's just for the joy of the contest.")
  end
end
