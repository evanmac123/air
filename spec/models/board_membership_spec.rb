require "spec_helper"

describe BoardMembership do
  it { should belong_to(:user) }
  it { should belong_to(:demo) }
  it { should belong_to(:location) }

  describe "after_destroy#update_or_destroy_user" do

    it "should destroy the user if the user has no other board memberships" do
      user = FactoryGirl.create(:user)

      user.demo.board_memberships.first.destroy

      expect(BoardMembership.count).to eq(0)
      expect(User.count).to eq(0)
    end

    it "should set the current board_membership to another board_membership if the current board membership is destroyed" do
      user = FactoryGirl.create(:user)
      board_2 = FactoryGirl.create(:demo)

      board_membership_2 = BoardMembership.create(user: user, demo: board_2, is_current: false)

      user.demo.board_memberships.first.destroy

      expect(BoardMembership.count).to eq(1)
      expect(BoardMembership.first.id).to eq(board_membership_2.id)
      expect(BoardMembership.first.is_current).to eq(true)
    end
  end
end
