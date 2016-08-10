#FIXME this entire logic needs to be completely rewritten. It is a utter cluster
#fuck.  
class CreateBoard
  include NormalizeBoardName
  attr_reader :board

  def initialize(board_name)
    @board_name = normalize_board_name(board_name)
  end

  def create
    @board = Demo.new(name: @board_name)

    set_board_defaults
    board_saved_successfully = @board.save
    # We do this separately so that we know the board has a unique public slug
    set_board_email if board_saved_successfully
  end

  protected

  def set_board_defaults
    @board.game_referrer_bonus = 5
    @board.referred_credit_bonus = 2
    @board.credit_game_referrer_threshold = 100000
  end

  def set_board_email
    email_local_part = @board.public_slug.gsub(/-/, '')
    offset = 2 # in case of a collision on the slug "foobar", we'll try "foobar2" first

    Demo.transaction do
      while (demo = Demo.find_by_email(email_local_part + "@ourairbo.com")).present?
        break if demo.id == @board.id
        email_local_part += offset.to_s
        offset += 1
      end
      @board.update_attributes(email: email_local_part + "@ourairbo.com")
    end
  end
end
