require 'acceptance/acceptance_helper'

feature 'Admin resets tickets for demo' do
  before(:each) do
    @demo = FactoryBot.create(:demo, :with_tickets)
    @user1 = FactoryBot.create(:user, :claimed, demo: @demo, tickets: 5, points: 104)
    @user2 = FactoryBot.create(:user, :claimed, demo: @demo, tickets: 0, points: 7)
    @user3 = FactoryBot.create(:user, :claimed, demo: @demo, tickets: 2, points: 59)
    @other_demo_user = FactoryBot.create(:user, :claimed, tickets: 666)

    [@user1, @user2, @user3, @other_demo_user].each{|user| has_password(user, 'foobar')}

    visit admin_demo_path(@demo, as: an_admin)

    click_link "Conduct raffle"

    click_button "Clear all tickets"
    
  end

  it "should drop the ticket count for all users in that demo to 0" do
    [@user1, @user2, @user3].each(&:reload)
    [@user1, @user2, @user3].each {|user| expect(user.tickets).to be_zero}
  end

  it "should not affect the ticket count of users in other demos" do
    expect(@other_demo_user.reload.tickets).not_to be_zero
  end

  it "should set the ticket threshold base of each affected user to its current point value" do
    [@user1, @user2, @user3].each(&:reload)
    expect(@user1.ticket_threshold_base).to eq(104)
    expect(@user2.ticket_threshold_base).to eq(7)
    expect(@user3.ticket_threshold_base).to eq(59)
    [@user1, @user2, @user3].each{|user| expect(user.to_ticket_progress_calculator.points_towards_next_threshold).to eq(0)}
  end
end
