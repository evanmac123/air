require 'spec_helper'

describe ExploresController do
  describe 'GET show' do
    it "should construe an email_type parameter to mean we came here by clicking an email, and ping accordingly" do
      subject.stubs(:ping)
      subject.stubs(:email_clicked_ping)
      subject.stubs(:explore_content_link_ping)

      user = FactoryGirl.create(:client_admin)
      user.intros.update_attributes(explore_intro_seen: false)

      get :show, explore_token: user.explore_token, email_type: "explore_v_1"

      expect(response.status).to eq(200)

      expect(subject).to have_received(:ping).with("Explore Onboarding", {"Source" => "Tiles Email"}, subject.current_user)
      expect(subject).to have_received(:email_clicked_ping)
      expect(subject).to have_received(:explore_content_link_ping)
    end
  end

  describe 'GET tile_tag_show' do
    it 'queues correct pings' do
      subject.stubs(:ping)
      subject.stubs(:ping_action_after_dash)

      client_admin = FactoryGirl.create(:client_admin)
      tile = FactoryGirl.create(:tile, :public)
      tile_tag = tile.tile_tags.first

      sign_in_as(client_admin)

      get :tile_tag_show, tag_click_source: "test", tile_tag: tile_tag

      expect(response.status).to eq(200)
      expect(subject).to have_received(:ping_action_after_dash).with("test", {tag: tile_tag.title}, subject.current_user)
      expect(subject).to have_received(:ping).with("Viewed Collection", {tag: tile_tag.title}, subject.current_user)
    end
  end
end
