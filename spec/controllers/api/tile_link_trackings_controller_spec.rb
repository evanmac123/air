require 'spec_helper'

describe Api::TileLinkTrackingsController do
  describe "POST create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:guest_user) { GuestUser.create }
    let(:tile) { FactoryGirl.create(:tile, activated_at: Tile::LinkTrackingConcern::TILE_LINK_TRACKING_RELEASE_DATE) }

    it "renders access denied if tile is not present" do
      sign_in_as(user)

      post(:create, { tile_id: 1, clicked_link: "test_link" })

      expect(response.status).to eq(403)
    end

    it "renders access denied if user is a guest" do
      sign_in_as(guest_user)

      post(:create, { tile_id: tile.id, clicked_link: "test_link" })

      expect(response.status).to eq(403)
    end

    it "renders access denied if user not present" do
      post(:create, { tile_id: tile.id, clicked_link: "test_link" })

      expect(response.status).to eq(403)
    end

    it "renders access denied if params[:clicked_link] not present" do
      sign_in_as(user)

      post(:create, { tile_id: tile.id })

      expect(response.status).to eq(403)
    end

    it "renders @tile.raw_link_click_stats when successful" do
      sign_in_as(user)

      post(:create, { tile_id: tile.id, clicked_link: "test_link" })

      expect(response.status).to eq(200)

      expect(JSON.parse(response.body)).to eq({"tile_id"=>tile.id, "data"=>{"unique_link_clicks"=>["1", "test_link"], "link_clicks"=>["1", "test_link"]}})
    end
  end
end
