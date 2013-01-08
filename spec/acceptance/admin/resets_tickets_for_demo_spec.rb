require 'acceptance/acceptance_helper'

feature 'Admin resets tickets for demo' do
  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_tickets)
    @user1 = FactoryGirl.create(:user, :claimed, demo: @demo, tickets: 5, points: 104)
    @user2 = FactoryGirl.create(:user, :claimed, demo: @demo, tickets: 0, points: 7)
    @user3 = FactoryGirl.create(:user, :claimed, demo: @demo, tickets: 2, points: 59)
    @other_demo_user = FactoryGirl.create(:user, :claimed, tickets: 666)

    [@user1, @user2, @user3, @other_demo_user].each{|user| has_password(user, 'foobar')}

    signin_as_admin
    visit admin_demo_path(@demo)
    click_link "Conduct raffle"

    click_button "Clear all tickets"
    crank_dj_clear
  end

  it "should drop the ticket count for all users in that demo to 0" do
    [@user1, @user2, @user3].each(&:reload)
    [@user1, @user2, @user3].each {|user| user.tickets.should be_zero}
  end

  it "should not affect the ticket count of users in other demos" do
    @other_demo_user.reload.tickets.should_not be_zero
  end

  it "should set the ticket threshold base of each affected user to its current point value" do
    [@user1, @user2, @user3].each(&:reload)
    @user1.ticket_threshold_base.should == 104
    @user2.ticket_threshold_base.should == 7
    @user3.ticket_threshold_base.should == 59
    [@user1, @user2, @user3].each{|user| user.points_towards_next_threshold.should == 0}
  end
end
