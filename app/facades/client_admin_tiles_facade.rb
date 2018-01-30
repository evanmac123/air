# frozen_string_literal: true

class ClientAdminTilesFacade
  attr_reader :demo, :all_tiles

  def initialize(demo:)
    @demo = demo
    @all_tiles = demo.tiles.group_by { |tile| tile.status }
  end

  def active_tiles
    tiles = tiles_by_grp(Tile::ACTIVE)
    Tile::PlaceholderManager.call(tiles)
  end

  def archive_tiles
    tiles = tiles_by_grp(Tile::ARCHIVE)[0, 4]
    Tile::PlaceholderManager.call(tiles)
  end

  def draft_tiles
    tiles = tiles_by_grp(Tile::DRAFT)
    Tile::PlaceholderManager.call(tiles, 6)
  end

  def suggested_tiles
    tiles = suggesteds
    Tile::PlaceholderManager.call(tiles, 6)
  end

  def user_submitted_tiles_counter
    submitteds.count
  end

  def allowed_to_suggest_users
    demo.users_that_allowed_to_suggest_tiles
  end

  private

    def tiles_by_grp(grp)
      tiles = all_tiles[grp] || []
      tiles.sort_by { |tile| tile.position }.reverse
    end

    def ignoreds
      tiles_by_grp(Tile::IGNORED)
    end

    def submitteds
      tiles_by_grp(Tile::USER_SUBMITTED)
    end

    def suggesteds
      submitteds.concat(ignoreds)
    end
end
