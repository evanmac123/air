require 'spec_helper'

describe RemoveUserFromBoard do
  def create_happy_path_user
    user = FactoryGirl.create(:user)
    other_board = FactoryGirl.create(:demo)
    user.add_board(other_board)
    expect(user.reload.demos.size).to eq(2)
    [user, other_board]
  end

  describe "#remove!" do
    context "when it's a paid board" do
      before do
        @user = FactoryGirl.create(:user)
        @paid_board = FactoryGirl.create(:demo, :paid)
        @user.add_board(@paid_board)

        expect(@user.demos.size).to eq(2)

        @remover = RemoveUserFromBoard.new(@user, @paid_board)
      end

      it "leaves them there, they cannot leave" do
        @remover.remove!
        expect(@user.reload.demos.size).to eq(2)
        expect(@user.demos).to include(@paid_board)
      end

      context "when the manual override option is selected" do
        it "should let them leave after all" do
          @remover = RemoveUserFromBoard.new(@user, @paid_board, override_paid: true)
          @remover.remove!
          expect(@user.reload.demos.size).to eq(1)
          expect(@user.demos).not_to include(@paid_board)
        end
      end

      it "returns false" do
        expect(@remover.remove!).to be_falsey
      end
    end

    context "when it's their only board" do
      before do
        @user = FactoryGirl.create(:user)
        expect(@user.demos.size).to eq(1)
        @original_demo_id = @user.demo_id
        @remover = RemoveUserFromBoard.new(@user, @original_demo_id)
      end

      it "leaves them there...for now, in the future this may delete their account" do
        @remover.remove!
        expect(@user.reload.demos.size).to eq(1)
        expect(@user.demo_id).to eq(@original_demo_id)
      end

      it "returns false" do
        expect(@remover.remove!).to be_falsey
      end
    end

    context "when removing the current board" do
      before do
        @user = FactoryGirl.create(:user)
        @user.add_board FactoryGirl.create(:demo)
      end

      it "leaves them in exactly one other board" do
        RemoveUserFromBoard.new(@user, @user.demo).remove!
        expect(@user.reload.board_memberships.size).to eq(1)
        expect(@user.board_memberships.first.is_current).to be_truthy
      end

      it "leaves them in the board where a tile was most recently posted" do
        2.times {@user.add_board FactoryGirl.create(:demo)}
        uncurrent_memberships = @user.board_memberships.where(is_current: false).to_a
        uncurrent_memberships.each_with_index do |membership, i|
          membership.demo.update_attributes(tile_last_posted_at: (i + 5).days.ago)
        end

        RemoveUserFromBoard.new(@user, @user.demo).remove!
        expect(@user.reload.demo).to eq(uncurrent_memberships.first.demo)
      end

      it "returns true" do
        remover = RemoveUserFromBoard.new(@user, @user.demo)
        expect(remover.remove!).to be_truthy
      end
    end

    it "leaves them without membership in the board in question, but still in others as previously" do
      user = FactoryGirl.create(:user)
      2.times {user.add_board(FactoryGirl.create(:demo))}
      expect(user.demos.size).to eq(3)
      original_demo_ids = user.demo_ids
      id_to_delete = original_demo_ids.last

      RemoveUserFromBoard.new(user, id_to_delete).remove!
      expect(user.reload.demos.size).to eq(2)
      expect(user.demo_ids.sort).to eq((original_demo_ids - [id_to_delete]).sort)
    end

    it "works if passed a Demo instead of just an ID" do
      user, other_board = create_happy_path_user
      RemoveUserFromBoard.new(user, other_board).remove!

      expect(user.reload.demos.size).to eq(1)
      expect(user.demos).not_to include(other_board)
    end

    it "returns true if successful" do
      user, other_board = create_happy_path_user
      remover = RemoveUserFromBoard.new(user, other_board)

      expect(remover.remove!).to be_truthy
    end
  end

  describe "#error_messages" do
    def expect_error(remover, expected_message)
      expect(remover.error_messages).to include(expected_message)
    end

    context "when this is their only board" do
      it "should have an appropriate message" do
        user = FactoryGirl.create(:user)
        expect(user.demos.size).to eq(1)

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
        expect(remover.error_messages).to eq([])
      end
    end
  end
end
