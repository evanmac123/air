require 'acceptance/acceptance_helper'

feature 'Admin resets gold coins for demo' do
  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_gold_coins)
    @user1 = FactoryGirl.create(:user, :claimed, demo: @demo, gold_coins: 5)
    @user2 = FactoryGirl.create(:user, :claimed, demo: @demo, gold_coins: 0)
    @user3 = FactoryGirl.create(:user, :claimed, demo: @demo, gold_coins: 2)
    @other_demo_user = FactoryGirl.create(:user, :claimed, gold_coins: 666)

    [@user1, @user2, @user3, @other_demo_user].each{|user| has_password(user, 'foobar')}

    signin_as_admin
    visit admin_demo_path(@demo)
    click_link "Conduct raffle"

    click_button "Clear all gold coins"
  end

  it "should drop the gold coin count for all users in that demo to 0" do
    [@user1, @user2, @user3].each(&:reload)
    [@user1, @user2, @user3].each {|user| user.gold_coins.should be_zero}
  end

  it "should not affect the gold coin count of users in other demos" do
    @other_demo_user.reload.gold_coins.should_not be_zero
  end
end
