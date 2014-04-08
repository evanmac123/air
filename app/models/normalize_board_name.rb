module NormalizeBoardName
  def normalize_board_name(board_name)
    _board_name = board_name.dup
    unless _board_name.blank? || _board_name.downcase.split.last == 'board'
      _board_name += " Board"
    end

    _board_name.strip!
    _board_name.gsub!(/\s+/, ' ')

    _board_name
  end
end
