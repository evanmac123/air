require 'rails_helper'

describe TileUserTargeter do
  let(:demo) { FactoryBot.create(:demo) }

  let(:user_1) { FactoryBot.create(:user, email: "user_1@airbo.com", name: "user 1", demo: demo) }
  let(:user_2) { FactoryBot.create(:user, email: "user_2@airbo.com", name: "user 2", demo: demo) }
  let(:user_3) { FactoryBot.create(:user, email: "user_3@airbo.com", name: "user 3", demo: demo) }
  let(:user_4) { FactoryBot.create(:user, email: "user_4@airbo.com", name: "user 4", demo: demo) }
  let(:user_5) { FactoryBot.create(:user, email: "user_5@airbo.com", name: "user 5", demo: demo) }
  let(:user_6) { FactoryBot.create(:user, email: "user_6@airbo.com", name: "user 6", demo: demo) }
  let(:user_7) { FactoryBot.create(:user, email: "user_7@airbo.com", name: "user 7", demo: demo) }

  let(:tile) { FactoryBot.create(:tile, multiple_choice_answers: ["a", "b", "c"], correct_answer_index: 0, demo: demo, activated_at: Time.current ) }

  before do
    Timecop.freeze(Time.local(1990))

    @users = [user_1, user_2, user_3, user_4, user_5, user_6, user_7]

    @activated_users = [user_1, user_2, user_3, user_4, user_5]
    @activated_users.each do |user|
      user.board_memberships.update_all(joined_board_at: tile.activated_at - 1.day)
    end

    @unactivated_users = [user_6]
    (@activated_users + @unactivated_users).each do |user|
      user.update_attributes(created_at: tile.activated_at - 1.day)
    end

    @users_created_before_tile_activation = @activated_users + @unactivated_users

    @users_added_after_tile_was_created = [user_7]
    @users_added_after_tile_was_created.each do |user|
      user.board_memberships.update_all(created_at: tile.activated_at + 1.day)
    end

    user_1.tile_completions.create(tile_id: tile.id, answer_index: 0)
    user_2.tile_completions.create(tile_id: tile.id, answer_index: 0)
    user_3.tile_completions.create(tile_id: tile.id, answer_index: 1)
  end

  after do
    Timecop.return
  end

  describe "#get_users" do
    describe "when scope is answered" do
      it "calls #users_who_answered" do
        rule = { scope: :answered, answer_idx: 0 }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        tile_user_targeter.expects(:users_who_answered).once.with(answer_idx: rule[:answer_idx])

        tile_user_targeter.get_users
      end
    end

    describe "when scope is did_not_answer" do
      it "calls #users_who_did_not_answer" do
        rule = { scope: :did_not_answer, answer_idx: 0 }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        tile_user_targeter.expects(:users_who_did_not_answer).once.with(answer_idx: rule[:answer_idx])

        tile_user_targeter.get_users
      end
    end

    describe "#users_who_answered" do
      describe "when answer is provided" do
        it "calls #users_who_answered_specific_answer" do
          rule = { scope: :answered, answer_idx: 0 }
          tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

          tile_user_targeter.expects(:users_who_answered_specific_answer).once.with(answer_idx: rule[:answer_idx])

          tile_user_targeter.users_who_answered(answer_idx: rule[:answer_idx])
        end
      end

      describe "when answer is nil" do
        it "returns all users who answered the tile" do
          rule = { scope: :answered, answer_idx: nil }
          tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

          users_who_answered = [user_1, user_2, user_3]
          users_from_targeter = tile_user_targeter.users_who_answered

          expect(users_from_targeter.pluck(:email).sort).to eq(users_who_answered.map(&:email).sort)
        end
      end
    end

    describe "#users_who_did_not_answer" do
      describe "when answer is provided" do
        it "calls #users_who_chose_different_answer" do
          rule = { scope: :answered, answer_idx: 0 }
          tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

          tile_user_targeter.expects(:users_who_chose_different_answer).once.with(answer_idx: rule[:answer_idx])

          tile_user_targeter.users_who_did_not_answer(answer_idx: rule[:answer_idx])
        end
      end

      describe "when answer is nil" do
        it "returns users who did not answer the tile" do
          rule = { scope: :answered, answer_idx: 0 }
          tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

          users_who_did_not_answer = [user_4, user_5, user_6, user_7]
          users_from_targeter = tile_user_targeter.users_who_did_not_answer

          expect(users_from_targeter.pluck(:email).sort).to eq(users_who_did_not_answer.map(&:email).sort)
        end
      end
    end

    describe "#users_who_answered_specific_answer" do
      it "returns users who answered the tile with the specified answer" do
        rule = { scope: :answered, answer_idx: 0 }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        users_who_answered_a = [user_1, user_2]
        users_from_targeter = tile_user_targeter.send(:users_who_answered_specific_answer, answer_idx: 0)

        expect(users_from_targeter.pluck(:email).sort).to eq(users_who_answered_a.map(&:email).sort)
      end
    end

    describe "#users_who_chose_different_answer" do
      it "returns users who did not answer the tile with the specified answer" do
        rule = { scope: :answered, answer_idx: 0 }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        users_who_did_not_answer_a = [user_3]
        users_from_targeter = tile_user_targeter.send(:users_who_chose_different_answer, answer_idx: 0)

        expect(users_from_targeter.pluck(:email).sort).to eq(users_who_did_not_answer_a.map(&:email).sort)
      end
    end

    describe "#targetable_users" do
      it "returns all the users that have access to the tile" do
        rule = { scope: :answered, answer_idx: 0 }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        targeted_users = tile_user_targeter.send(:targetable_users)

        expect(targeted_users.pluck(:email).sort).to eq(@users.map(&:email).sort)
      end
    end
  end
end
