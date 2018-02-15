# frozen_string_literal: true

class Tile::StatusUpdater
  def self.call(tile:, new_status: nil)
    Tile::StatusUpdater.new(tile, new_status).perform
  end

  def initialize(tile, new_status)
    @_tile = tile
    @_new_status = new_status
  end

  def perform
    return unless Tile::STATUS.include?(new_status)
    update_status
    tile.tap(&:save)
  end

  private

    def tile
      @_tile
    end

    def new_status
      @_new_status
    end

    def update_status
      tile.status = new_status
    end
end
