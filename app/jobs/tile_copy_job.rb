# frozen_string_literal: true

class TileCopyJob < ActiveJob::Base
  queue_as :high_priority

  def perform(tile:, demo:, user:)
    TileCopier.new(demo, tile, user).copy_tile_from_explore
  end
end
