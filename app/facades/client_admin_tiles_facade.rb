# frozen_string_literal: true

class ClientAdminTilesFacade
  attr_reader :demo, :all_tiles

  def initialize(demo:)
    @demo = demo
    @all_tiles = demo.tiles.group_by { |tile| tile.status }
  end

  def active_tiles
    tiles = demo.tiles.active.page(1).per(16)
    Tile::PlaceholderManager.call(tiles)
  end

  def archive_tiles
    tiles = demo.tiles.archive.page(1).per(16)
    Tile::PlaceholderManager.call(tiles)
  end

  def draft_tiles
    tiles = demo.tiles.draft.page(1).per(16)
    Tile::PlaceholderManager.call(tiles)
  end

  def suggested_tiles
    tiles = demo.tiles.suggested.page(1).per(16)
    Tile::PlaceholderManager.call(tiles)
  end

  def allowed_to_suggest_users
    demo.users_that_allowed_to_suggest_tiles
  end
end
