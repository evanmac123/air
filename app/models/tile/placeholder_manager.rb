# frozen_string_literal: true

class Tile::PlaceholderManager
  def self.call(tiles, row_size = 4)
    Tile::PlaceholderManager.new(tiles, row_size).tiles_with_placeholders
  end

  attr_reader :tiles, :row_size

  def initialize(tiles, row_size)
    @tiles = tiles
    @row_size = row_size
  end

  def tiles_with_placeholders
    placeholders_to_add.times { tiles << Tile::Placeholder.new }
    tiles
  end

  private

    def incomplete_row_length
      tiles.length % row_size
    end

    def placeholders_to_add
      row_size - incomplete_row_length
    end
end
