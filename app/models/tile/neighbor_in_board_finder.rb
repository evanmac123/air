# frozen_string_literal: true

class Tile::NeighborInBoardFinder
  def initialize(tile)
    @_tile = tile
  end

  def next
    tiles.where("position < ?", tile.position).first || tiles.first
  end

  def prev
    tiles.where("position > ?", tile.position).last || tiles.last
  end

  private

    def tile
      @_tile
    end

    def tiles
      demo = tile.demo
      demo.tiles.where(status: tile.status).order(position: :desc)
    end
end
