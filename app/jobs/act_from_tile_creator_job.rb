# frozen_string_literal: true

class ActFromTileCreatorJob < ActiveJob::Base
  queue_as :default

  def perform(tile:, user:)
    Act.create_from_tile_completion(tile: tile, user: user)
  end
end
