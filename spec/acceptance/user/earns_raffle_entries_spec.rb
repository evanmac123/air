require 'acceptance/acceptance_helper'

metal_testing_hack(SmsController)

feature 'User earns tickets' do
  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_tickets, ticket_threshold: 10)
    @user = FactoryGirl.create(:user, :claimed, :with_phone_number, demo: @demo)
    @raffle = @demo.raffle = FactoryGirl.create(:raffle, :live, demo: @demo)

    rule1 = FactoryGirl.create(:rule, demo: @demo, points: 9)
    FactoryGirl.create(:primary_value, value: 'rule1', rule: rule1)

    rule2 = FactoryGirl.create(:rule, demo: @demo, points: 1)
    FactoryGirl.create(:primary_value, value: 'rule2', rule: rule2)

    rule3 = FactoryGirl.create(:rule, demo: @demo, points: 2)
    FactoryGirl.create(:primary_value, value: 'rule3', rule: rule3)

    has_password @user, 'foobar'
    signin_as @user, 'foobar'
    expect_raffle_entries 0
  end

  it "should award a ticket every time the user passes the threshold" do
    mo_sms(@user.phone_number, 'rule1')   # 9 points
    visit acts_path(as: @user)
    expect_raffle_entries 0

    mo_sms(@user.phone_number, 'rule2')   # 10 points
    visit acts_path(as: @user)
    expect_raffle_entries 1

    mo_sms(@user.phone_number, 'rule1')   # 19 points
    visit acts_path(as: @user)
    expect_raffle_entries 1

    mo_sms(@user.phone_number, 'rule3')   # 21 points
    visit acts_path(as: @user)
    expect_raffle_entries 2

    mo_sms(@user.phone_number, 'rule2')   # 22 points
    visit acts_path(as: @user)
    expect_raffle_entries 2
  end

  it "should award multiple tickets if the user gets a lot of points" do
    rule4 = FactoryGirl.create(:rule, demo: @demo, points: 20)
    FactoryGirl.create(:primary_value, value: 'rule4', rule: rule4)

    rule5 = FactoryGirl.create(:rule, demo: @demo, points: 30)
    FactoryGirl.create(:primary_value, value: 'rule5', rule: rule5)

    mo_sms(@user.phone_number, 'rule4')
    visit acts_path(as: @user)
    expect_raffle_entries 2

    mo_sms(@user.phone_number, 'rule5')
    visit acts_path(as: @user)
    expect_raffle_entries 5
  end
end
