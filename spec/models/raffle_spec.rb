require 'spec_helper'

describe Raffle do
  it { should have_many(:user_in_raffle_infos) }
  it { should have_many(:user_winners) }
  it { should have_many(:blacklisted_users) }

  describe "#pick_winners" do
    before(:each) do
      @demo = FactoryGirl.create(:demo)
      @raffle = FactoryGirl.create(:raffle, demo: @demo)
      @users = FactoryGirl.create_list(:user, 4, :with_tickets, demo: @demo)
    end

    it "should have no winner or blacklisted user at the start" do
      @raffle.winners.should == []
      @raffle.blacklisted_users.should == []
      @raffle.demo.users.pluck(:email).should == @users.map(&:email)
    end

    it "should pick required number of winners" do
      @raffle.pick_winners 2
      @raffle.winners.count.should == 2
      @raffle.blacklisted_users.should == []
    end

    it "should put previous winners in blacklist" do
      @raffle.pick_winners 2
      old_winners_id = @raffle.reload.winners.pluck(:id)
      @raffle.pick_winners 2
      @raffle.reload.blacklisted_users.pluck(:id).should == old_winners_id
    end

    it "should not repeat winner" do
      @raffle.pick_winners 2
      old_winners = @raffle.reload.winners.dup
      @raffle.pick_winners 2
      old_winners.should_not == @raffle.reload.winners
    end
  end
end
