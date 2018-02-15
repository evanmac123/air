# frozen_string_literal: true

class ClientAdminTilesFacade
  attr_reader :tiles, :tile_counts, :allowed_to_suggest_users

  def initialize(demo:)
    @tiles = demo.tiles
    @tile_counts = demo.tiles.group(:status).count
    @allowed_to_suggest_users = demo.users_that_allowed_to_suggest_tiles
  end

  def archive_tiles
    tiles.archive.ordered_by_position.page(1).per(16)
  end

  def active_tiles
    tiles.active.ordered_by_position.page(1).per(16)
  end

  def draft_tiles
    tiles.draft.ordered_by_position.page(1).per(16)
  end

  def plan_tiles
    tiles.plan.ordered_by_position.page(1).per(16)
  end

  def suggested_tiles
    tiles.suggested.ordered_by_position.page(1).per(16)
  end
end
