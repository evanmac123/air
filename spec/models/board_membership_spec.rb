require "spec_helper"

describe BoardMembership do
  it { should belong_to(:user) }
  it { should belong_to(:demo) }
  it { should belong_to(:location) }

  describe "after_destroy#destroy_dependent_user" do
    before do
      primary_board = FactoryGirl.create( :demo, :with_dependent_board)
      @primary_user = FactoryGirl.create(:user, demo: primary_board)

      @dependent_board = primary_board.dependent_board

      @alt_primary_user = FactoryGirl.create(:user)
      @alt_spouse = FactoryGirl.create(:user, demo: @dependent_board, primary_user: @alt_primary_user)
    end

    it "should destroy dependent user from dependent board" do
      spouse = FactoryGirl.create(:user, primary_user: @primary_user, demo: @dependent_board)

      expect(@dependent_board.users.pluck(:id).sort).to eq([@alt_spouse.id, spouse.id].sort)
      expect(User.pluck(:id).sort).to eq([@primary_user.id, @alt_primary_user.id, @alt_spouse.id, spouse.id].sort)

      @primary_user.current_board_membership.destroy

      expect(@dependent_board.reload.users.pluck(:id)).to eq([@alt_spouse.id])
      expect(User.pluck(:id).sort).to eq([@primary_user.id, @alt_primary_user.id, @alt_spouse.id].sort)
    end

    it "should remove user form dependent board and move to another" do
      spouse = FactoryGirl.create :user, primary_user: @primary_user, demo: @dependent_board
      d2 = FactoryGirl.create :demo
      spouse.add_board(d2)

      expect(@dependent_board.users.pluck(:id).sort).to eq([@alt_spouse.id, spouse.id].sort)

      @primary_user.current_board_membership.destroy

      expect(@dependent_board.reload.users.pluck(:id)).to eq([@alt_spouse.id])
      expect(User.pluck(:id).sort).to eq([@primary_user.id, @alt_primary_user.id, @alt_spouse.id, spouse.id].sort)
      expect(d2.reload.users.pluck(:id)).to eq([spouse.id])
    end
  end
end
