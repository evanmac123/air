require 'spec_helper'

describe Explore::CopyTilesController do
  describe "POST create" do
    it "should send appropriate pings" do
      client_admin = FactoryGirl.create(:client_admin)
      sign_in_as(client_admin)

      tile = FactoryGirl.create(:tile, is_public: true, status: Tile::ACTIVE)

      post :create, tile_id: tile.id

      expect(client_admin.rdb['copies'].sismember(tile.id)).to eq(1)
    end
  end
end
