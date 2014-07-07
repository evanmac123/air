require 'spec_helper'

describe RemoveUserFromBoard do
  describe "#remove!" do
    context "when it's a paid board" do
      it "leaves them there, they cannot leave" do
        user = FactoryGirl.create(:user)
        paid_board = FactoryGirl.create(:demo, :paid)
        user.add_board(paid_board)

        user.should have(2).demos
        
        RemoveUserFromBoard.new(user, paid_board).remove!
        user.reload.should have(2).demos
        user.demos.should include(paid_board)
      end
    end

    context "when it's their only board" do
      it "leaves them there...for now, in the future this may delete their account" do
        user = FactoryGirl.create(:user)
        user.should have(1).demos
        original_demo_id = user.demo_id

        RemoveUserFromBoard.new(user, original_demo_id).remove!
        user.reload.should have(1).demos
        user.demo_id.should == original_demo_id
      end
    end

    context "when removing the current board" do
      before do
        @user = FactoryGirl.create(:user)
        @user.add_board FactoryGirl.create(:demo)
      end

      it "leaves them in exactly one other board" do
        RemoveUserFromBoard.new(@user, @user.demo).remove!
        @user.reload.should have(1).board_membership
        @user.board_memberships.first.is_current.should be_true
      end

      it "leaves them in the board where a tile was most recently posted" do
        2.times {@user.add_board FactoryGirl.create(:demo)}
        uncurrent_memberships = @user.board_memberships.where(is_current: false).to_a
        uncurrent_memberships.each_with_index do |membership, i|
          membership.demo.update_attributes(tile_last_posted_at: (i + 5).days.ago)
        end

        RemoveUserFromBoard.new(@user, @user.demo).remove!
        @user.reload.demo.should == uncurrent_memberships.first.demo
      end
    end

    it "leaves them without membership in the board in question, but still in others as previously" do
      user = FactoryGirl.create(:user)
      2.times {user.add_board(FactoryGirl.create(:demo))}
      user.should have(3).demos
      original_demo_ids = user.demo_ids
      id_to_delete = original_demo_ids.last

      RemoveUserFromBoard.new(user, id_to_delete).remove!
      user.reload.should have(2).demos
      user.demo_ids.sort.should == (original_demo_ids - [id_to_delete]).sort
    end

    it "works if passed a Demo instead of just an ID" do
      user = FactoryGirl.create(:user)
      other_board = FactoryGirl.create(:demo)
      user.add_board(other_board)
      user.reload.should have(2).demos

      RemoveUserFromBoard.new(user, other_board).remove!

      user.reload.should have(1).demos
      user.demos.should_not include(other_board)
    end
  end
end
