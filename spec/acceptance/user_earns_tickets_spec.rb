require 'acceptance/acceptance_helper'

feature 'User earns tickets' do
  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_tickets, ticket_threshold: 10)
    @user = FactoryGirl.create(:user, :claimed, demo: @demo)

    rule1 = FactoryGirl.create(:rule, demo: @demo, points: 9)
    FactoryGirl.create(:primary_value, value: 'rule1', rule: rule1)

    rule2 = FactoryGirl.create(:rule, demo: @demo, points: 1)
    FactoryGirl.create(:primary_value, value: 'rule2', rule: rule2)

    rule3 = FactoryGirl.create(:rule, demo: @demo, points: 2)
    FactoryGirl.create(:primary_value, value: 'rule3', rule: rule3)

    has_password @user, 'foobar'
    signin_as @user, 'foobar'
    expect_ticket_header 0
  end

  it "should award a ticket every time the user passes the threshold" do
    act_via_play_box 'rule1'   # 9 points
    expect_ticket_header 0

    act_via_play_box 'rule2'   # 10 points
    expect_ticket_header 1

    act_via_play_box 'rule1'   # 19 points
    expect_ticket_header 1

    act_via_play_box 'rule3'   # 21 points
    expect_ticket_header 2

    act_via_play_box 'rule2'   # 22 points
    expect_ticket_header 2
  end
end
