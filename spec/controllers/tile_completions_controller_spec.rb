require "spec_helper"

describe TileCompletionsController do
  it "should not let you complete a tile for a board you're not in" do
    subject.stubs(:ping)

    tile = FactoryGirl.create(:tile)
    user = FactoryGirl.create(:user)

    user.should_not be_in_board(tile.demo_id)
    TileCompletion.count.should == 0

    sign_in_as user
    post :create, tile_id: tile.id

    response.should be_not_found
    TileCompletion.count.should == 0
  end
end
