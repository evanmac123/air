class BoardCopier
  attr_reader :new_board, :board_template

  def initialize(new_board, board_template)
    @new_board = new_board
    @board_template = board_template
  end

  def copy_active_tiles_from_board
    board_template.active_tiles.reverse.each do |tile|
      TileCopier.new(new_board, tile).copy_from_own_board(Tile::ACTIVE, "Initial Board Setup")
    end
  end
end
