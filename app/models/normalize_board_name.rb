module NormalizeBoardName
  def normalize_board_name(board_name)
    # We use [[:space:]] here instead of the more concise \s because \s
    # apparently doesn't match the non-breaking spaces, which contenteditable
    # DOM elements seem to like to put in.

    _board_name = board_name.dup
    unless _board_name.blank? || _board_name.downcase.split(/[[:space:]]+/).last == 'board'
      _board_name += " Board"
    end

    _board_name.strip!
    _board_name.gsub!(/[[:space:]]+/, ' ')

    _board_name
  end
end
