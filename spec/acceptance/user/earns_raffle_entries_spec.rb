require 'acceptance/acceptance_helper'

metal_testing_hack(SmsController)

feature 'User earns tickets' do
  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_tickets, ticket_threshold: 10)
    @user = FactoryGirl.create(:user, :claimed, :with_phone_number, demo: @demo)
    @raffle = @demo.raffle = FactoryGirl.create(:raffle, :live, demo: @demo)

    visit acts_path(as: @user)
    expect_raffle_entries 0
  end

  it "should award a ticket every time the user passes the threshold" do
    @user.update_points(9)
    visit acts_path(as: @user)
    expect_raffle_entries 0

    @user.update_points(1) # 10 total
    visit acts_path(as: @user)
    expect_raffle_entries 1

    @user.update_points(9) # 19 total
    visit acts_path(as: @user)
    expect_raffle_entries 1

    @user.update_points(2) # 21 total
    visit acts_path(as: @user)
    expect_raffle_entries 2

    @user.update_points(1) # 22 total
    visit acts_path(as: @user)
    expect_raffle_entries 2
  end

  it "should award multiple tickets if the user gets a lot of points" do
    @user.update_points(20)
    visit acts_path(as: @user)
    expect_raffle_entries 2

    @user.update_points(30)
    visit acts_path(as: @user)
    expect_raffle_entries 5
  end
end
