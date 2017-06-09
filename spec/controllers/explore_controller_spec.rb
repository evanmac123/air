require 'spec_helper'

describe ExploreController do
  describe "pings" do
    let(:client_admin) { FactoryGirl.create :client_admin }
    it "should send tile email tracking ping when there is a user and the params specify email type and a tile email id" do
      subject.stubs(:explore_email_clicked_ping)

      sign_in_as(client_admin)

      get :show, {
        email_type: "explore_digest",
        email_version: "1/1/17",
      }

      expect(subject).to have_received(:explore_email_clicked_ping).with({
        user: client_admin,
        email_type: "explore_digest",
        email_version: "1/1/17"
      })
    end

    it "should NOT send tile email tracking ping when the params do not specify email type and a tile email id" do
      subject.stubs(:explore_email_clicked_ping)

      sign_in_as(client_admin)

      get :show

      expect(subject).to have_received(:explore_email_clicked_ping).never
    end
  end
end
