require 'spec_helper'

describe TileController do
  describe "GET show" do
    it "sends appropriate pings" do
      subject.stubs(:ping)
      subject.stubs(:tile_viewed_ping)

      tile = FactoryGirl.create(:multiple_choice_tile, is_sharable: true)

      get :show, id: tile.id
      expect(subject).to have_received(:tile_viewed_ping)
    end
  end
end
