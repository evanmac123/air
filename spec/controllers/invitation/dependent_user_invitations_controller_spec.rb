require 'spec_helper'

describe Invitation::DependentUserInvitationsController do
  describe "#create" do
    before do
      demo = FactoryBot.create(:demo, :with_dependent_board)
      sign_in_as(FactoryBot.create(:user, demo: demo))
    end

    context "when email present" do
      render_views

      it "should be successful" do
        post :create, dependent_user_invitation: {email: "good@gmail.com", subject: "Join Us", body: "Yep"}

        expect(response).to be_success

        expect(response.body).to match(/Invite Sent!/)
        expect(PotentialUser.last.email).to eq("good@gmail.com")
      end

      context "when email not present" do
        render_views

        it "should be successful" do
          post :create, dependent_user_invitation: {subject: "Join Us", body: "Yep"}

          expect(response.body).to match(/User already in Board./)
        end
      end
    end
  end
end
