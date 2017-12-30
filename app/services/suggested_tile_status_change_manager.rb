class SuggestedTileStatusChangeManager
  def initialize tile
    @tile = tile
  end

  def process
    case
    when tile_approved?
      send_acceptance_email
    when tile_posted?
      send_posted_email
    when user_submitted?
      send_submitted_email
    end
  end

  private

  def send_acceptance_email
    send_mail(:accepted)
  end

  def send_posted_email
    send_mail(:posted)
  end

  def send_submitted_email
    ReviewSubmittedTileMailer.notify_all @tile.creator.id,@tile.demo.id
  end

  def send_mail msg_type
    SuggestedTileStatusMailer.delay.notify(message_type: msg_type, user: @tile.creator, tile: @tile)
  end

  def tile_approved?
    is_eligible_with_state_change? [Tile::USER_SUBMITTED, Tile::DRAFT]
  end

  def tile_posted?
    is_eligible_with_state_change? [Tile::DRAFT, Tile::ACTIVE]
  end

  def user_submitted?
    @tile.new_record? && is_eligible_with_state_change?([nil, Tile::USER_SUBMITTED])
  end

  def is_eligible_with_state_change? state_change
    @tile.user_created? && @tile.creator && state_change == @tile.changes[:status]
  end
end
