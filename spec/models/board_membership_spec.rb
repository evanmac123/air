require "spec_helper"

describe BoardMembership do
  it { should belong_to(:user) }
  it { should belong_to(:demo) }
  it { should belong_to(:location) }

  describe "after_destroy#destroy_dependent_user" do
    it "destroys dependent users for this user from dependent board" do
      primary_user = FactoryGirl.create :user, demo: FactoryGirl.create( :demo, :with_dependent_board)
      dep_d = primary_user.demo.dependent_board

      u1 = FactoryGirl.create :user, primary_user: primary_user, demo: dep_d
      expect(dep_d.users.pluck(:id)).to eq([u1.id])

      primary_user.current_board_membership.destroy

      expect(dep_d.reload.users.pluck(:id)).to eq([])
      expect(User.all).to eq [primary_user]
    end
  end
end
