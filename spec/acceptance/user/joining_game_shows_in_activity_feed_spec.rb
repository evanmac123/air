require 'acceptance/acceptance_helper'

metal_testing_hack(SmsController)

feature 'User joining game shows as act' do
  before(:each) do
    demo = FactoryGirl.create(:demo, :with_phone_number)
    @fred = FactoryGirl.create(:user, name: "Fred Fredricksen", privacy_level: "everybody", claim_code: "fred", demo: demo)
    @bob = FactoryGirl.create(:user, name: "Bob", demo: demo)
    has_password(@bob, 'foobar')

    mo_sms "+14152613077", "fred", demo.phone_number
    @fred.reload.should be_claimed

    signin_as @bob, 'foobar'
  end

  scenario 'in activity feed' do
    visit activity_path
    expect_content "Fred Fredricksen joined"
  end

  scenario 'on profile page' do
    visit user_path(@fred)
    expect_content "Fred Fredricksen joined"
  end
end
