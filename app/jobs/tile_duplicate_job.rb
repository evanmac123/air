# frozen_string_literal: true

class TileDuplicateJob < ActiveJob::Base
  queue_as :default

  def perform(tile:, demo:, user:)
    TileCopier.new(demo, tile, user).copy_from_own_board
  end
end
