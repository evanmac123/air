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

  context "in a demo with a fixed gold coin award" do
    before(:each) do
      @demo.minimum_ticket_award = @demo.maximum_ticket_award = 3
      @demo.save!
    end

    it "should award that fixed amount every time the user passes the threshold" do
      act_via_play_box 'rule1'   # 9 points
      expect_ticket_header 0

      act_via_play_box 'rule2'   # 10 points
      expect_ticket_header 3

      act_via_play_box 'rule1'   # 19 points
      expect_ticket_header 3

      act_via_play_box 'rule3'   # 21 points
      expect_ticket_header 6

      act_via_play_box 'rule2'   # 22 points
      expect_ticket_header 6
    end
  end

  context "in a demo with separate gold coin awards" do
    before(:each) do
      @demo.minimum_ticket_award = 1
      @demo.maximum_ticket_award = 3
      @demo.save!
    end

    it "should award something in that range" do
      User.any_instance.stubs(:rand).with(@demo.ticket_spread + 1).returns(0,1,2)
      act_via_play_box 'rule1'   # 9 points
      expect_ticket_header 0

      act_via_play_box 'rule2'   # 10 points
      expect_ticket_header 1

      act_via_play_box 'rule1'   # 19 points
      expect_ticket_header 1

      act_via_play_box 'rule3'   # 21 points
      expect_ticket_header 3

      act_via_play_box 'rule2'   # 22 points
      expect_ticket_header 3

      act_via_play_box 'rule1'   # 31 points
      expect_ticket_header 6

      act_via_play_box 'rule2'   # 32 points
      expect_ticket_header 6
    end
  end
end
