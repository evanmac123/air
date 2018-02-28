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
      case new_status
      when Tile::ACTIVE
        assign_activate
      when Tile::ARCHIVE
        assign_archive
      else
        assign_default
      end
    end

    def assign_activate
      tile.assign_attributes(
        status: Tile::ACTIVE,
        activated_at: Time.current,
        archived_at: nil
      )
    end

    def assign_archive
      tile.assign_attributes(
        status: Tile::ARCHIVE,
        archived_at: Time.current
      )
    end

    def assign_default
      tile.status = new_status
    end
end
