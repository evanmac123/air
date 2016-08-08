require 'spec_helper'

describe RemoveUserFromBoard do
  def create_happy_path_user
    user = FactoryGirl.create(:user)
    other_board = FactoryGirl.create(:demo)
    user.add_board(other_board)
    user.reload.should have(2).demos
    [user, other_board]
  end

  describe "#remove!" do
    context "when it's a paid board" do
      before do
        @user = FactoryGirl.create(:user)
        @paid_board = FactoryGirl.create(:demo, :paid)
        @user.add_board(@paid_board)

        @user.should have(2).demos

        @remover = RemoveUserFromBoard.new(@user, @paid_board)
      end

      it "leaves them there, they cannot leave" do
        @remover.remove!
        @user.reload.should have(2).demos
        @user.demos.should include(@paid_board)
      end

      context "when the manual override option is selected" do
        it "should let them leave after all" do
          @remover = RemoveUserFromBoard.new(@user, @paid_board, override_paid: true)
          @remover.remove!
          @user.reload.should have(1).demos
          @user.demos.should_not include(@paid_board)
        end
      end

      it "returns false" do
        @remover.remove!.should be_false
      end
    end

    context "when it's their only board" do
      before do
        @user = FactoryGirl.create(:user)
        @user.should have(1).demos
        @original_demo_id = @user.demo_id
        @remover = RemoveUserFromBoard.new(@user, @original_demo_id)
      end

      it "leaves them there...for now, in the future this may delete their account" do
        @remover.remove!
        @user.reload.should have(1).demos
        @user.demo_id.should == @original_demo_id
      end

      it "returns false" do
        @remover.remove!.should be_false
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

      it "returns true" do
        remover = RemoveUserFromBoard.new(@user, @user.demo)
        remover.remove!.should be_true
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
      user, other_board = create_happy_path_user
      RemoveUserFromBoard.new(user, other_board).remove!

      user.reload.should have(1).demos
      user.demos.should_not include(other_board)
    end

    it "returns true if successful" do
      user, other_board = create_happy_path_user
      remover = RemoveUserFromBoard.new(user, other_board)

      remover.remove!.should be_true
    end
  end

  describe "#error_messages" do
    def expect_error(remover, expected_message)
      remover.error_messages.should include(expected_message)
    end

    context "when this is their only board" do
      it "should have an appropriate message" do
        user = FactoryGirl.create(:user)
        user.should have(1).demos

        remover = RemoveUserFromBoard.new(user, user.demo)
        expect_error remover, "you can't leave your last board"
      end
    end

    context "when this is a paid board" do
      it "should have an appropriate message" do
        user = FactoryGirl.create(:user)
        board_to_remove = FactoryGirl.create(:demo, :paid)
        user.add_board(board_to_remove)

        remover = RemoveUserFromBoard.new(user, board_to_remove)
        expect_error remover, "you can't leave a paid board"
      end
    end

    context "when things are fine" do
      it "should be an empty list" do
        user, board = create_happy_path_user
        remover = RemoveUserFromBoard.new(user, board)
        remover.error_messages.should == []
      end
    end
  end
end
