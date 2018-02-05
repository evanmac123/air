require 'rails_helper'

RSpec.describe TileDuplicateJob, type: :job do
  it "asks TileCopier to copy_from_own_board" do
    demo = Demo.new
    tile = demo.tiles.new
    user = User.new
    mock_tile_copier = OpenStruct.new

    TileCopier.expects(:new).with(demo, tile, user).returns(mock_tile_copier)
    mock_tile_copier.expects(:copy_from_own_board)

    TileDuplicateJob.perform_now(tile: tile, demo: demo, user: user)
  end
end
