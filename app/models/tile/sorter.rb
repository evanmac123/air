# frozen_string_literal: true

class Tile::Sorter
  def self.call(tile:, left_tile_id: nil)
    Tile::Sorter.new(tile, left_tile_id).perform
  end

  def initialize(tile, left_tile_id)
    @_tile = tile
    @_left_tile = Tile.find_by(id: left_tile_id)
  end

  def perform
    Tile.transaction do
      set_tile_position
      update_tile_positions_to_the_left
    end

    tile
  end

  private

    def tile
      @_tile
    end

    def left_tile
      @_left_tile
    end

    def set_tile_position
      tile.position = new_tile_position
      tile.save
    end

    def new_tile_position
      if left_tile
        left_tile.position
      else
        tiles_in_section.maximum(:position).to_i + 1
      end
    end

    def tiles_in_section
      tile.demo.tiles.where(status: tile.status)
    end

    def update_tile_positions_to_the_left
      tiles_in_section.where("position >= ?", tile.position).where.not(id: tile.id).update_all("position = position + 1")
    end
end
