# frozen_string_literal: true

class ClientAdminTilesFacade
  attr_reader :demo, :tile_counts

  def initialize(demo:)
    @demo = demo
    @tile_counts = demo.tiles.group(:status).count
  end

  def active_tiles
    demo.tiles.active.page(1).per(16)
  end

  def archive_tiles
    demo.tiles.archive.page(1).per(16)
  end

  def draft_tiles
    demo.tiles.draft.page(1).per(16)
  end

  def suggested_tiles
    demo.tiles.suggested.page(1).per(16)
  end

  def allowed_to_suggest_users
    demo.users_that_allowed_to_suggest_tiles
  end
end
