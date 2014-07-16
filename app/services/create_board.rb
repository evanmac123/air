class CreateBoard
  include NormalizeBoardName

  def initialize(board_name)
    @board_name = normalize_board_name(board_name)
  end

  def create
    @board = Demo.new(name: @board_name)

    set_board_defaults
    board_saved_successfully = @board.save
    # We do this separately so that we know the board has a unique public slug

    if board_saved_successfully
      email_local_part = @board.public_slug.gsub(/-/, '')
      @board.update_attributes(email: email_local_part + "@ourairbo.com")
    end
  end

  def set_board_defaults
    @board.game_referrer_bonus = 5
    @board.referred_credit_bonus = 2
    @board.credit_game_referrer_threshold = 100000
  end

  attr_reader :board
end
