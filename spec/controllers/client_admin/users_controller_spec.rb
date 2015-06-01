require 'spec_helper'

describe ClientAdmin::UsersController do
  describe "#create on an existing user, thereby inviting them into a new board" do
    it "should set their is_client_admin flag on the BoardMembership for the new board, not the one they're currently in" do
      existing_user = FactoryGirl.create(:user, email: 'john@doe.com')
      existing_user.is_client_admin = true
      existing_user.save!

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
  end
end
