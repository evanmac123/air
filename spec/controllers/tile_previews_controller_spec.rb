require 'spec_helper'

describe TilePreviewsController do
  describe 'GET show' do
    it "should construe an email_type parameter to mean we came here by clicking an email, and ping accordingly" do
      subject.stubs(:ping)
      subject.stubs(:email_clicked_ping)
      organization = FactoryGirl.create(:organization, name: "Airbo")
      user = FactoryGirl.create(:client_admin)
      tile = FactoryGirl.create(:tile, :public, organization: organization)

      xhr :get, :show, id: tile.id, explore_token: user.explore_token, email_type: "explore_v_1"

      expect(response.status).to eq(200)
      expect(subject).to have_received(:email_clicked_ping)
    end

    it "should return 404 error if tile is not found" do
      get :show, id: 0
      response.status.should == 404
    end
  end
end
