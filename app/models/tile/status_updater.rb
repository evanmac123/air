# frozen_string_literal: true

class Tile::StatusUpdater
  def self.call(tile:, new_status: nil, redigest: nil)
    Tile::StatusUpdater.new(tile, new_status, redigest).perform
  end

  def initialize(tile, new_status, redigest)
    @_tile = tile
    @_new_status = new_status
    @_redigest = redigest
  end

  def perform
    return unless Tile::STATUS.include?(new_status)
    handle_unarchived
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

    def redigest
      @_redigest
    end

    def handle_unarchived
      if redigesting?
        tile.activated_at = Time.current
      end
    end

    def redigesting?
      tile.status == Tile::ARCHIVE && new_status == Tile::ACTIVE && redigest == "true"
    end

    def update_status
      tile.status = new_status
    end
end
