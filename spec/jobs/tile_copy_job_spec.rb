require 'rails_helper'

RSpec.describe TileCopyJob, type: :job do
  it "asks TileCopier to copy_tile_from_explore" do
    demo = Demo.new
    tile = demo.tiles.new
    user = User.new
    mock_tile_copier = OpenStruct.new

    TileCopier.expects(:new).with(demo, tile, user).returns(mock_tile_copier)
    mock_tile_copier.expects(:copy_tile_from_explore)

    TileCopyJob.perform_now(tile: tile, demo: demo, user: user)
  end
end
