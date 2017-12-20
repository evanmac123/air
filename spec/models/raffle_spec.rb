require 'spec_helper'

describe Raffle do
  it { is_expected.to have_many(:user_in_raffle_infos) }
  it { is_expected.to have_many(:winners) }

  let(:demo) { FactoryBot.create(:demo) }
  let(:raffle) { FactoryBot.create(:raffle, demo: demo) }

  describe "#pick_winners" do
    it "should pick required number of winners" do
      users = FactoryBot.create_list(:user, 3, :with_tickets, demo: demo)

      raffle.pick_winners 2
      expect(raffle.winners.count).to eq(2)
    end

    it "puts winners in blacklist" do
      users = FactoryBot.create_list(:user, 2, :with_tickets, demo: demo)

      raffle.pick_winners(1)
      first_winner_ids = raffle.winners.pluck(:id)

      expect(raffle.send(:blacklisted_user_ids)).to eq(first_winner_ids)
    end

    it "should not repeat winner" do
      users = FactoryBot.create_list(:user, 6, :with_tickets, demo: demo)

      raffle.pick_winners(3)
      old_winners = raffle.winners.pluck(:id).sort

      raffle.pick_winners(3)

      expect(raffle.winners.count).to eq(old_winners.count)
      expect(old_winners).not_to eq(raffle.winners.pluck(:id).sort)
    end

    it "picks fewer winners if the pool runs out of people" do
      users = FactoryBot.create_list(:user, 3, :with_tickets, demo: demo)

      raffle.pick_winners(4)

      expect(raffle.winners.count).to eq(3)
    end
  end

  describe "#repick_winner" do
    it "keeps the winner that needs to be repicked in the blacklist" do
      users = FactoryBot.create_list(:user, 3, :with_tickets, demo: demo)
      winners = raffle.pick_winners(2)
      bad_winner = winners.first

      raffle.repick_winner(bad_winner)

      expect(raffle.send(:blacklisted_user_ids).include?(bad_winner.id)).to be true
    end

    it "replaces a former winner with a new winner" do
      users = FactoryBot.create_list(:user, 2, :with_tickets, demo: demo)
      winners = raffle.pick_winners(1)
      bad_winner = winners.first
      good_winner = (users - [bad_winner]).first

      expect(raffle.winners.pluck(:id)).to eq([bad_winner.id])

      raffle.repick_winner(bad_winner)

      expect(raffle.winners.pluck(:id)).to eq([good_winner.id])
    end

    it "does not add duplicate winners" do
      users = FactoryBot.create_list(:user, 1, :with_tickets, demo: demo)
      winners = raffle.pick_winners(1)
      bad_winner = winners.first

      raffle.repick_winner(bad_winner)

      expect(raffle.winners.empty?).to be true
    end

    it "returns the new winner" do
      users = FactoryBot.create_list(:user, 2, :with_tickets, demo: demo)
      winners = raffle.pick_winners(1)
      bad_winner = winners.first

      new_winner = raffle.repick_winner(bad_winner)

      expect(new_winner).to eq((users - [bad_winner]).first)
    end
  end

  describe "#show_start?" do
    it "creates a user_in_raffle_info for user" do
      user = FactoryBot.create(:user, :with_tickets, demo: demo)

      expect(user.user_in_raffle_infos.count).to eq(0)
      expect(raffle.user_in_raffle_infos.count).to eq(0)

      raffle.show_start?(user)

      expect(user.user_in_raffle_infos.count).to eq(1)
      expect(raffle.user_in_raffle_infos.count).to eq(1)
    end

    it "updates the start_showed to true" do
      user = FactoryBot.create(:user, :with_tickets, demo: demo)

      raffle.expects(:live?).returns(true)
      UserInRaffleInfo.any_instance.expects(:update_attributes).with({ start_showed: true })

      raffle.show_start?(user)
    end

    it "does not update if the raffle is not live" do
      user = FactoryBot.create(:user, :with_tickets, demo: demo)
      expect(raffle.live?).to be false

      UserInRaffleInfo.any_instance.expects(:update_attributes).never

      raffle.show_start?(user)
    end

    it "does not update if the attr is already set to true" do
      user = FactoryBot.create(:user, :with_tickets, demo: demo)

      raffle.expects(:live?).returns(true)
      UserInRaffleInfo.any_instance.expects(:start_showed).returns(true)
      UserInRaffleInfo.any_instance.expects(:update_attributes).never

      raffle.show_start?(user)
    end
  end

  describe "#show_finish?" do
    it "creates a user_in_raffle_info for user" do
      user = FactoryBot.create(:user, :with_tickets, demo: demo)

      expect(user.user_in_raffle_infos.count).to eq(0)
      expect(raffle.user_in_raffle_infos.count).to eq(0)

      raffle.show_finish?(user)

      expect(user.user_in_raffle_infos.count).to eq(1)
      expect(raffle.user_in_raffle_infos.count).to eq(1)
    end

    it "updates the finish_showed to true" do
      user = FactoryBot.create(:user, :with_tickets, demo: demo)

      raffle.expects(:finished?).returns(true)
      UserInRaffleInfo.any_instance.expects(:start_showed).returns(true)
      UserInRaffleInfo.any_instance.expects(:update_attributes).with({ finish_showed: true })

      raffle.show_finish?(user)
    end

    it "does not update if the raffle is not finished" do
      user = FactoryBot.create(:user, :with_tickets, demo: demo)
      expect(raffle.finished?).to be false

      UserInRaffleInfo.any_instance.expects(:update_attributes).never

      raffle.show_finish?(user)
    end

    it "does not update if the attr is already set to true" do
      user = FactoryBot.create(:user, :with_tickets, demo: demo)

      raffle.expects(:finished?).returns(true)
      UserInRaffleInfo.any_instance.expects(:finish_showed).returns(true)
      UserInRaffleInfo.any_instance.expects(:update_attributes).never

      raffle.show_finish?(user)
    end

    it "does not update if the start was not shown" do
      user = FactoryBot.create(:user, :with_tickets, demo: demo)

      raffle.expects(:finished?).returns(true)
      UserInRaffleInfo.any_instance.expects(:finish_showed).returns(false)
      UserInRaffleInfo.any_instance.expects(:update_attributes).never

      raffle.show_finish?(user)
    end
  end
end
