require 'spec_helper'

describe TilesController do
  describe "#index" do
    def expect_no_start_tile_set_for_user(user)
      tile = FactoryBot.create(:tile)
      expect(tile.demo_id).to_not eq(user.demo_id)
      expect(tile.is_sharable).to be_falsey

      get :index, nil, {start_tile: tile.id}
      expect(assigns[:start_tile]).to be_nil
    end

    context "as a regular user requesting a tile that's not sharable in a board you're not in" do
      it "should not assign that to @start_tile" do
        subject.stubs(:ping)
        tile = FactoryBot.create(:tile)
        user = FactoryBot.create(:user)

        expect(tile.demo_id).to_not eq(user.demo_id)
        expect(tile.is_sharable).to be_falsey

        sign_in_as(user)
        get :index, nil, { start_tile: tile.id }

        expect(assigns(:start_tile)).to be_nil
      end
    end

    context "as a guest requesting a tile that's not sharable in a board you're not in" do
      it "should not assign that to @start_tile" do
        subject.stubs(:ping)
        tile = FactoryBot.create(:tile)
        user = FactoryBot.create(:guest_user)

        expect(tile.demo_id).to_not eq(user.demo_id)
        expect(tile.is_sharable).to be_falsey

        sign_in_as(user)
        get :index, nil, { start_tile: tile.id }

        expect(assigns(:start_tile)).to be_nil
      end
    end

    xit "should send appropriate ping" do
      # FIXME: MIXPANEL additional test cases related to this ping should be tested client side after mixpanel audit.  i.e. clicking to next tile.
      subject.stubs(:ping)

      demo = FactoryBot.create(:demo)
      tile = FactoryBot.create(:tile, demo: demo, is_sharable: true)
      client_admin = FactoryBot.create(:client_admin)

      sign_in_as(client_admin)

      get :index, nil, { start_tile: tile.id }

      expect(subject).to have_received(:ping).with('Tile - Viewed', {:tile_type=>"User", :tile_id=>tile.id, :board_type=>"Free"}, subject.send(:current_user))
      expect(subject).to have_received(:ping).with('Activity Session - New', anything, subject.send(:current_user))
    end
  end
end
