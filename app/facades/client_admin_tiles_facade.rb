# frozen_string_literal: true

class ClientAdminTilesFacade
  attr_reader :tiles, :tile_counts

  def initialize(demo:)
    @tiles = demo.tiles
    @tile_counts = tiles.group(:status).count
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
