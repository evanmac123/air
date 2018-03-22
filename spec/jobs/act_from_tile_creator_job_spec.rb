require 'rails_helper'

RSpec.describe ActFromTileCreatorJob, type: :job do
  it "asks Act to create from tile completion" do
    user = "user"
    tile = "tile"

    Act.expects(:create_from_tile_completion).with(user: user, tile: tile)

    ActFromTileCreatorJob.perform_later(user: user, tile: tile)
  end
end
