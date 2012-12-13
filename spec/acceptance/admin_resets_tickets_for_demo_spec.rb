require 'acceptance/acceptance_helper'

feature 'Admin resets gold coins for demo' do
  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_tickets)
    @user1 = FactoryGirl.create(:user, :claimed, demo: @demo, tickets: 5)
    @user2 = FactoryGirl.create(:user, :claimed, demo: @demo, tickets: 0)
    @user3 = FactoryGirl.create(:user, :claimed, demo: @demo, tickets: 2)
    @other_demo_user = FactoryGirl.create(:user, :claimed, tickets: 666)

    [@user1, @user2, @user3, @other_demo_user].each{|user| has_password(user, 'foobar')}

    signin_as_admin
    visit admin_demo_path(@demo)
    click_link "Conduct raffle"

    click_button "Clear all tickets"
  end

  it "should drop the ticket count for all users in that demo to 0" do
    [@user1, @user2, @user3].each(&:reload)
    [@user1, @user2, @user3].each {|user| user.tickets.should be_zero}
  end

  it "should not affect the ticket count of users in other demos" do
    @other_demo_user.reload.tickets.should_not be_zero
  end
end
