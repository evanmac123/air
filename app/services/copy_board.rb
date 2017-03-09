class CopyBoard
  attr_reader :new_board, :board_template

  def initialize(new_board, board_template)
    @new_board = new_board
    @board_template = board_template
  end

  def copy_active_tiles_from_board
    tile_copier = CopyTile.new(new_board)

    board_template.active_tiles.reverse.each do |tile|
      tile_copier.copy_tile(tile, false, Tile::ACTIVE)
    end
  end
end
