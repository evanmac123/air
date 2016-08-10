require 'spec_helper'

describe CopyTilesController do
  describe "POST create" do
    it "should send appropriate pings" do
      subject.stubs(:ping)
      subject.stubs(:schedule_copy_ping)
      subject.stubs(:schedule_tile_creation_ping)

      client_admin = FactoryGirl.create(:client_admin)
      sign_in_as(client_admin)

      tile = FactoryGirl.create(:tile, is_copyable: true, is_public: true, status: Tile::ACTIVE)

      post :create, tile_id: tile.id

      expect(subject).to have_received(:schedule_copy_ping).with(tile)
      expect(subject).to have_received(:schedule_tile_creation_ping)
    end
  end
end
