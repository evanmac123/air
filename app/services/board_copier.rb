# frozen_string_literal: true

class BoardCopier
  def self.call(board, template)
    BoardCopier.new(board, template).perform
  end

  attr_reader :new_board, :board_template

  def initialize(new_board, board_template)
    @new_board = new_board
    @board_template = board_template
  end

  def perform
    board_template.active_tiles.reverse.each do |tile|
      TileCopier.new(new_board, tile).copy_from_template
    end
  end
end
