class CopyBoard
  attr_reader :new_board, :board_template

  def initialize(new_board, board_template)
    @new_board = new_board
    @board_template = board_template
  end

  def copy_active_tiles_from_board
    board_template.active_tiles.reverse.each do |tile|
      copy_tile(tile)
    end
  end

  def copy_tile(tile)
    copy = tile.class.new
    copy_tile_data(tile, copy)
    set_new_data_for_copy(tile, copy)
    copy.save
    copy
  end

  protected

  def copy_tile_data(tile, copy)
    [
      "correct_answer_index",
      "headline",
      "multiple_choice_answers",
      "points",
      "question",
      "supporting_content",
      "question_type",
      "question_subtype",
      "remote_media_url",
      "status"
    ].each do |field_to_copy|
      copy.send("#{field_to_copy}=", tile.send(field_to_copy))
    end
  end

  def set_new_data_for_copy(tile, copy)
    copy.demo = new_board
    copy.position = copy.find_new_first_position
  end
end
