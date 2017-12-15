require 'spec_helper'


describe BulkUserDeletionJob do

  before do
    @demo = FactoryGirl.create(:demo)
    @other_demo = FactoryGirl.create(:demo)
    FactoryGirl.create_list(:board_membership, 9, demo: @demo)
    FactoryGirl.create_list(:board_membership, 2, is_client_admin: true,demo: @demo)
    FactoryGirl.create_list(:board_membership, 2,demo: @other_demo)
  end

  it "has correct number of starting ordinary users" do
    users_count = @demo.board_memberships.where(is_client_admin: false).count
    expect(users_count).to eq(9)
  end

  it "has correct number of starting client admin users" do
    client_admins_count = @demo.board_memberships.where(is_client_admin: true).count
    expect(client_admins_count).to eq(2)
  end

  context "ordinary users only" do
    before do
      BulkUserDeletionJob.new({demo_id: @demo.id, ordinary_users: true}).perform
    end

    it "deletes ordinary users"  do
      users_count = @demo.board_memberships.where(is_client_admin: false).count
      expect(users_count).to eq(0)
    end

    it "preserve client admin users"  do
      client_admins_count = @demo.board_memberships.where(is_client_admin: true).count
      expect(client_admins_count).to eq(2)
    end
  end

  context "client admins only" do
    before do
      BulkUserDeletionJob.new({demo_id: @demo.id,client_admins: true}).perform
    end

    it "preserves ordinary users"  do
      users_count = @demo.board_memberships.where(is_client_admin: false).count
      expect(users_count).to eq(9)
    end

    it "deletes client admins users"  do
      client_admins_count = @demo.board_memberships.where(is_client_admin: true).count
      expect(client_admins_count).to eq(0)
    end

  end

  context "all users" do
    before do
      FactoryGirl.create(:user, is_site_admin: true, demo: @demo)
      BulkUserDeletionJob.new({demo_id: @demo.id, ordinary_users: true, client_admins: true}).perform
    end

    it "doesn't delete users in unrelated boards" do
      expect(@other_demo.users.count).to eq(2)
    end

    it "deletes all users except for site admin"  do
      users_count = @demo.board_memberships.where(is_client_admin: false).count
      expect(users_count).to eq(1)
    end
  end
end
