require "spec_helper"

describe BoardMembership do
  it { should belong_to(:user) }
  it { should belong_to(:demo) }
  it { should belong_to(:location) }

  describe "after_destroy#destroy_dependent_user" do
    before do
      @primary_user = FactoryGirl.create :user, demo: FactoryGirl.create( :demo, :with_dependent_board)
      @dep_d = @primary_user.demo.dependent_board

      @other_u = FactoryGirl.create :user, demo: @dep_d, primary_user: FactoryGirl.create(:user)
      @other_u_prim = @other_u.primary_user
    end

    it "should destroy dependent user from dependent board" do
      u1 = FactoryGirl.create :user, primary_user: @primary_user, demo: @dep_d
      expect(@dep_d.users.pluck(:id)).to eq([@other_u.id, u1.id])
      expect(User.pluck(:id)).to eq [@primary_user.id, @other_u_prim.id, @other_u.id, u1.id]

      @primary_user.current_board_membership.destroy

      expect(@dep_d.reload.users.pluck(:id)).to eq([@other_u.id])
      expect(User.pluck(:id)).to eq [@primary_user.id, @other_u_prim.id, @other_u.id]
    end

    it "should remove user form dependent board and move to another" do
      u1 = FactoryGirl.create :user, primary_user: @primary_user, demo: @dep_d
      d2 = FactoryGirl.create :demo
      u1.add_board(d2)

      expect(@dep_d.users.pluck(:id)).to eq([@other_u.id, u1.id])

      @primary_user.current_board_membership.destroy

      expect(@dep_d.reload.users.pluck(:id)).to eq([@other_u.id])
      expect(User.pluck(:id)).to eq [@primary_user.id, @other_u_prim.id, @other_u.id, u1.id]
      expect(d2.reload.users.pluck(:id)).to eq([u1.id])
    end
  end
end
