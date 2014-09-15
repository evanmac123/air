require 'spec_helper'

describe TilePreviewsController do
  describe '#show' do
    it "should construe an email_type parameter to mean we came here by clicking an email, and ping accordingly" do
      user = FactoryGirl.create(:client_admin)
      tile = FactoryGirl.create(:tile, :public)

      get :show, id: tile.id, explore_token: user.explore_token, email_type: "explore_v_1"

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching('Email clicked', {email_type: "Explore - v. 8/25/14"}.merge(user.data_for_mixpanel))
    end

    it "should return 404 error if tile is not found" do
      get :show, id: 0
      response.status.should == 404
    end
  end
end
