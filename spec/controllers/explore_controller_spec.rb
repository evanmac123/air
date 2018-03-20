require 'spec_helper'

describe ExploreController do
  describe "pings" do
    let(:client_admin) { FactoryBot.create :client_admin }
    it "should send tile email tracking ping when there is a user and the params specify email type and a tile email id" do
      props = {
        email_type: "explore_digest",
        email_version: "1/1/17",
      }

      subject.expects(:explore_email_clicked_ping)

      sign_in_as(client_admin)

      get :show, props
    end

    it "should NOT send tile email tracking ping when the params do not specify email type and a tile email id" do
      subject.expects(:explore_email_clicked_ping).never

      sign_in_as(client_admin)

      get :show
    end
  end
end
