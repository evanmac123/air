require 'spec_helper'

describe Raffle do
  it { is_expected.to have_many(:user_in_raffle_infos) }
  it { is_expected.to have_many(:user_winners) }
  it { is_expected.to have_many(:blacklisted_users) }

  describe "#pick_winners" do
    before(:each) do
      @demo = FactoryGirl.create(:demo)
      @raffle = FactoryGirl.create(:raffle, demo: @demo)
      @users = FactoryGirl.create_list(:user, 4, :with_tickets, demo: @demo)
    end

    it "should have no winner or blacklisted user at the start" do
      expect(@raffle.winners).to eq([])
      expect(@raffle.blacklisted_users).to eq([])
      arr1 = @raffle.demo.users.pluck(:email)
      arr2 = @users.map(&:email)
      expect{arr1 & arr2 == arr1}.to be_truthy
    end

    it "should pick required number of winners" do
      @raffle.pick_winners 2
      expect(@raffle.winners.count).to eq(2)
      expect(@raffle.blacklisted_users).to eq([])
    end

    it "should put previous winners in blacklist" do
      @raffle.pick_winners 2
      old_winners_id = @raffle.reload.winners.pluck(:id)
      @raffle.pick_winners 2
      expect(@raffle.reload.blacklisted_users.pluck(:id)).to eq(old_winners_id)
    end

    it "should not repeat winner" do
      @raffle.pick_winners 2
      old_winners = @raffle.reload.winners.dup
      @raffle.pick_winners 2
      expect(old_winners).not_to eq(@raffle.reload.winners)
    end
  end
end
