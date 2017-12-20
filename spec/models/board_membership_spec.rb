require "spec_helper"

describe BoardMembership do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:demo) }
  it { is_expected.to belong_to(:location) }

  describe "after_destroy#update_or_destroy_user" do

    it "should destroy the user if the user has no other board memberships" do
      user = FactoryBot.create(:user)

      user.demo.board_memberships.first.destroy

      expect(BoardMembership.count).to eq(0)
      expect(User.count).to eq(0)
    end

    it "should set the current board_membership to another board_membership if the current board membership is destroyed" do
      user = FactoryBot.create(:user)
      board_2 = FactoryBot.create(:demo)

      board_membership_2 = BoardMembership.create(user: user, demo: board_2, is_current: false)

      user.demo.board_memberships.first.destroy

      expect(BoardMembership.count).to eq(1)
      expect(BoardMembership.first.id).to eq(board_membership_2.id)
      expect(BoardMembership.first.is_current).to eq(true)
    end
  end
end
