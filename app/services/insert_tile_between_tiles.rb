# frozen_string_literal: true

class InsertTileBetweenTiles
  def initialize(tile, left_tile_id)
    @tile = tile
    @left_tile = Tile.find_by(id: left_tile_id)
  end

  def insert!
    Tile.transaction do
      set_tile_position
      update_tile_positions_to_the_left
    end
  end

  private

    def set_tile_position
      @tile.position = new_tile_position
      @tile.save
    end

    def new_tile_position
      if @left_tile
        @left_tile.position
      else
        tiles_in_section.maximum(:position).to_i + 1
      end
    end

    def tiles_in_section
      @tile.demo.tiles.where(status: @tile.status)
    end

    def update_tile_positions_to_the_left
      tiles_in_section.where("position >= ?", @tile.position).where.not(id: @tile.id).update_all("position = position + 1")
    end
end
