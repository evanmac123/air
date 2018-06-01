require 'spec_helper'


describe UserRemovalJob do

  before do
    @demo = FactoryBot.create(:demo)
    @other_demo = FactoryBot.create(:demo)
    @user = FactoryBot.create(:user, demo: @demo)
    FactoryBot.create_list(:user, 9, demo: @demo)
    FactoryBot.create_list(:user, 2, demo: @other_demo)
    FactoryBot.create(:board_membership, demo: @other_demo, user: @user)
  end

  it "has correct number of starting users in boards" do
    demo_users_count = @demo.users.count
    other_demo_users_count = @other_demo.users.count
    total_user_count = User.count

    expect(demo_users_count).to eq(10)
    expect(other_demo_users_count).to eq(3)
    expect(total_user_count).to eq(12)
  end

  it "has one user attached to both boards" do
    user_demo_count = @user.demos.count

    expect(user_demo_count).to eq(2)
  end

  context "remove one user" do
    before do
      UserRemovalJob.new(demo_id: @demo.id, user_ids: [@user.id]).perform
    end

    it "deletes user from board"  do
      users_count = @demo.users.count

      expect(users_count).to eq(9)
    end

    it "preserves user existence in other boards"  do
      user_demos = @user.demos
      total_user_count = User.count

      expect(user_demos.count).to eq(1)
      expect(user_demos.where(id: @demo.id)).to eq([])
      expect(total_user_count).to eq(12)
    end
  end

  context "multiple users are removed" do
    before do
      @users = @demo.users[1..5]
      UserRemovalJob.new(demo_id: @demo.id, user_ids: @users).perform
    end

    it "deletes users from board"  do
      users_count = @demo.users.count

      expect(users_count).to eq(5)
    end

    it "deletes user from database if removed from only board"  do
      total_user_count = User.count

      expect(total_user_count).to eq(7)
    end
  end

  context "user removed from all boards" do
    before do
      UserRemovalJob.new(demo_id: @demo.id, user_ids: [@user.id]).perform
      UserRemovalJob.new(demo_id: @other_demo.id, user_ids: [@user.id]).perform
    end

    it "removes user from both boards" do
      demo_count = @demo.users.count
      other_demo_count = @other_demo.users.count

      expect(demo_count).to eq(9)
      expect(other_demo_count).to eq(2)
    end

    it "deletes user from database"  do
      total_user_count = User.count

      expect(total_user_count).to eq(11)
      expect(User.find_by(id: @user.id)).to eq(nil)
    end
  end
end
