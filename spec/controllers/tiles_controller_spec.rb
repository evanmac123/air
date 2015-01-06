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
        expect_no_start_tile_set_for_user(FactoryGirl.create(:user))
      end
    end

    context "as a guest requesting a tile that's not sharable in a board you're not in" do
      it "should not assign that to @start_tile" do
        expect_no_start_tile_set_for_user(FactoryGirl.create(:guest_user))
      end
    end
  end
end
