require 'rails_helper'

describe TileUserTargeter do
  let(:demo) { FactoryGirl.create(:demo) }

  let(:user_1) { FactoryGirl.create(:user, email: "user_1@airbo.com", name: "user 1", demo: demo) }
  let(:user_2) { FactoryGirl.create(:user, email: "user_2@airbo.com", name: "user 2", demo: demo) }
  let(:user_3) { FactoryGirl.create(:user, email: "user_3@airbo.com", name: "user 3", demo: demo) }
  let(:user_4) { FactoryGirl.create(:user, email: "user_4@airbo.com", name: "user 4", demo: demo) }
  let(:user_5) { FactoryGirl.create(:user, email: "user_5@airbo.com", name: "user 5", demo: demo) }
  let(:user_6) { FactoryGirl.create(:user, email: "user_6@airbo.com", name: "user 6", demo: demo) }
  let(:user_7) { FactoryGirl.create(:user, email: "user_7@airbo.com", name: "user 7", demo: demo) }

  let(:tile) { FactoryGirl.create(:tile, multiple_choice_answers: ["a", "b", "c"], correct_answer_index: 0, demo: demo) }

  before do
    Timecop.freeze(Time.local(1990))

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
        rule = { scope: :answered, answer: "a" }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        tile_user_targeter.expects(:users_who_answered).once.with(answer: rule[:answer])

        tile_user_targeter.get_users
      end
    end

    describe "when scope is did_not_answer" do
      it "calls #users_who_did_not_answer" do
        rule = { scope: :did_not_answer, answer: "a" }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        tile_user_targeter.expects(:users_who_did_not_answer).once.with(answer: rule[:answer])

        tile_user_targeter.get_users
      end
    end

    describe "#users_who_answered" do
      describe "when answer is provided" do
        it "calls #users_who_answered_specific_answer" do
          rule = { scope: :answered, answer: "a" }
          tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

          tile_user_targeter.expects(:users_who_answered_specific_answer).once.with(answer: rule[:answer])

          tile_user_targeter.users_who_answered(answer: rule[:answer])
        end
      end

      describe "when answer is nil" do
        it "returns all users who answered the tile" do
          rule = { scope: :answered, answer: nil }
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
          rule = { scope: :answered, answer: "a" }
          tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

          tile_user_targeter.expects(:users_who_chose_different_answer).once.with(answer: rule[:answer])

          tile_user_targeter.users_who_did_not_answer(answer: rule[:answer])
        end
      end

      describe "when answer is nil" do
        it "returns users who did not answer the tile" do
          rule = { scope: :answered, answer: "a" }
          tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

          users_who_did_not_answer = [user_4, user_5, user_6]
          users_from_targeter = tile_user_targeter.users_who_did_not_answer

          expect(users_from_targeter.pluck(:email).sort).to eq(users_who_did_not_answer.map(&:email).sort)
        end
      end
    end

    describe "#users_who_answered_specific_answer" do
      it "returns users who answered the tile with the specified answer" do
        rule = { scope: :answered, answer: "a" }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        users_who_answered_a = [user_1, user_2]
        users_from_targeter = tile_user_targeter.send(:users_who_answered_specific_answer, answer: "a")

        expect(users_from_targeter.pluck(:email).sort).to eq(users_who_answered_a.map(&:email).sort)
      end
    end

    describe "#users_who_chose_different_answer" do
      it "returns users who did not answer the tile with the specified answer" do
        rule = { scope: :answered, answer: "a" }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        users_who_did_not_answer_a = [user_3]
        users_from_targeter = tile_user_targeter.send(:users_who_chose_different_answer, answer: "a")

        expect(users_from_targeter.pluck(:email).sort).to eq(users_who_did_not_answer_a.map(&:email).sort)
      end
    end

    describe "#targetable_users" do
      describe "when the tile has a tiles_digest and the tiles_digest does not include unclaimed users" do
        it "calls #targetable_users_claimed_only" do
          tiles_digest = demo.tiles_digests.create(include_unclaimed_users: false)
          tiles_digest.tiles << tile

          rule = { scope: :answered, answer: "a" }
          tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

          tile_user_targeter.expects(:targetable_users_claimed_only).once

          tile_user_targeter.send(:targetable_users)
        end
      end

      describe "when the tile does not have a tiles digest" do
        it "calls #targetable_users_all" do
          rule = { scope: :answered, answer: "a" }
          tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

          tile_user_targeter.expects(:targetable_users_all).once

          tile_user_targeter.send(:targetable_users)
        end
      end

      describe "when the tile has a tiles digest that includes unclaimed users" do
        it "calls #targetable_users_all" do
          tiles_digest = demo.tiles_digests.create(include_unclaimed_users: true)
          tiles_digest.tiles << tile

          rule = { scope: :answered, answer: "a" }
          tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

          tile_user_targeter.expects(:targetable_users_all).once

          tile_user_targeter.send(:targetable_users)
        end
      end
    end

    describe "#targetable_users_claimed_only" do
      it "returns all the users that were activated before the tile was activated" do
        rule = { scope: :answered, answer: "a" }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        tageted_users = tile_user_targeter.send(:targetable_users_claimed_only)

        expect(tageted_users.pluck(:email).sort).to eq(@activated_users.map(&:email).sort)
      end
    end

    describe "#targetable_users_all" do
      it "returns all the users that were created before the tile was activated" do
        rule = { scope: :answered, answer: "a" }
        tile_user_targeter = TileUserTargeter.new(tile: tile, rule: rule)

        tageted_users = tile_user_targeter.send(:targetable_users_all)

        expect(tageted_users.pluck(:email).sort).to eq(@users_created_before_tile_activation.map(&:email).sort)
      end
    end
  end
end
