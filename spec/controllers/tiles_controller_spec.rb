require 'spec_helper'

describe TilesController do
  describe "#index" do
    def expect_no_start_tile_set_for_user(user)
      tile = FactoryGirl.create(:tile)
      tile.demo_id.should_not == user.demo_id
      tile.is_sharable.should be_false

      @controller.current_user = user

      get :index, nil, {start_tile: tile.id}
      assigns[:start_tile].should be_nil
    end

    context "as a regular user requesting a tile that's not sharable in a board you're not in" do
      it "should not assign that to @start_tile" do
        subject.stubs(:ping)

        expect_no_start_tile_set_for_user(FactoryGirl.create(:user))
      end
    end

    context "as a guest requesting a tile that's not sharable in a board you're not in" do
      it "should not assign that to @start_tile" do
        subject.stubs(:ping)

        expect_no_start_tile_set_for_user(FactoryGirl.create(:guest_user))
      end
    end

    it "should send appropriate ping" do
      # FIXME: MIXPANEL additional test cases related to this ping should be tested client side after mixpanel audit.  i.e. clicking to next tile.
      subject.stubs(:ping)

      demo = FactoryGirl.create(:demo)
      tile = FactoryGirl.create(:tile, demo: demo, is_sharable: true)
      client_admin = FactoryGirl.create(:client_admin)

      sign_in_as(client_admin)

      get :index, nil, {start_tile: tile.id}

      expect(subject).to have_received(:ping).with('Tile - Viewed', {:tile_type=>"User", :tile_id=>tile.id, :board_type=>"Free"}, subject.current_user)
      expect(subject).to have_received(:ping).with('Activity Session - New', anything, subject.current_user)
    end
  end
end
