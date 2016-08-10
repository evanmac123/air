require 'spec_helper'

describe TilePreviewsController do
  describe 'GET show' do
    it "should construe an email_type parameter to mean we came here by clicking an email, and ping accordingly" do
      subject.stubs(:ping)
      subject.stubs(:email_clicked_ping)
      subject.stubs(:explore_intro_ping)
      user = FactoryGirl.create(:client_admin)
      tile = FactoryGirl.create(:tile, :public)

      xhr :get, :show, id: tile.id, explore_token: user.explore_token, email_type: "explore_v_1"

      expect(response.status).to eq(200)
      expect(subject).to have_received(:ping).with("Tile - Viewed in Explore", {tile_id: tile.id}, subject.current_user)
      expect(subject).to have_received(:ping).with('Tile - Viewed', {tile_type: "Public Tile - Explore", tile_id: tile.id}, subject.current_user)
      expect(subject).to have_received(:email_clicked_ping)
      expect(subject).to have_received(:explore_intro_ping)
    end

    it "should return 404 error if tile is not found" do
      get :show, id: 0
      response.status.should == 404
    end
  end
end
