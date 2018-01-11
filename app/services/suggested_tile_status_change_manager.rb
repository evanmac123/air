class SuggestedTileStatusChangeManager
  attr_reader :tile

  def initialize(tile)
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
      SuggestedTileStatusMailer.notify_accepted(user: tile.creator, tile: tile).deliver_later
    end

    def send_posted_email
      SuggestedTileStatusMailer.notify_posted(user: tile.creator, tile: tile).deliver_later
    end

    def send_submitted_email
      ReviewSuggestedTileBulkMailJob.perform_later(tile: tile)
    end

    def tile_approved?
      is_eligible_with_state_change?([Tile::USER_SUBMITTED, Tile::DRAFT])
    end

    def tile_posted?
      is_eligible_with_state_change?([Tile::DRAFT, Tile::ACTIVE])
    end

    def user_submitted?
      is_eligible_with_state_change?([nil, Tile::USER_SUBMITTED])
    end

    def is_eligible_with_state_change?(state_change)
      tile.suggestion_box_created? && tile.creator && state_change == tile.changes[:status]
    end
end
