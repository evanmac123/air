require 'spec_helper'

describe ClientAdmin::UsersController do
  describe "POST create" do
    context "existing user" do
      it "should set their is_client_admin flag on the BoardMembership for the new board, not the one they're currently in" do
        subject.stubs(:ping)

        existing_user = FactoryGirl.create(:user, email: 'john@doe.com', is_client_admin: true)
        original_board = existing_user.demo
        client_admin = FactoryGirl.create(:client_admin)

        sign_in_as(client_admin)

        post :create, user: {name: 'unused', email: 'john@doe.com', role: 'User'}

        existing_user.reload
        existing_user.should have(2).board_memberships

        new_board_membership = existing_user.board_memberships.where("demo_id != ?", original_board.id).first
        new_board_membership.is_client_admin.should be_false

        existing_user.is_client_admin.should be_true
      end

      it "should send appropriate pings" do
        subject.stubs(:ping)

        existing_user = FactoryGirl.create(:user)
        client_admin = FactoryGirl.create(:client_admin)

        sign_in_as(client_admin)

        post :create, user: {email: existing_user.email}

        expect(subject).to have_received(:ping).with("User - Existing Invited", source: 'creator')
      end
    end

    context "new user" do
      it "should send appropriate pings" do
        subject.stubs(:ping)

        client_admin = FactoryGirl.create(:client_admin)

        sign_in_as(client_admin)

        post :create, user: {name: "Test User", email: "test@example.com"}

        expect(subject).to have_received(:ping).with("User - New", source: 'creator')
      end
    end
  end
end
