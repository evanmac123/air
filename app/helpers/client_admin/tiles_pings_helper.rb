# frozen_string_literal: true

module ClientAdmin::TilesPingsHelper
  def tile_status_updated_ping(tile, action)
    ping("Moved Tile in Manage", { action: action, tile_id: tile.id }, current_user)
  end

  def tile_in_box_updated_ping(tile)
    status = tile.status

    if status == Tile::DRAFT
      ping_tile_accepted(tile)
    elsif status == Tile::IGNORED
      ping_tile_ignored(tile)
    end
  end

  def schedule_tile_creation_ping(tile, source)
    ping("Tile - New", tile_creation_ping_props(tile, source), current_user)
  end

  def tile_in_box_viewed_ping(tile)
    return unless tile.suggested?
    ping("Suggestion Box", { client_admin_action: "Tile Viewed", tile_id: tile.id }, current_user)
  end

  def tile_creation_ping_props(tile, source)
    {
      tile_source: source,
      is_public: tile.is_public
    }
  end

  private

    def ping_tile_accepted(tile)
      ping("Suggestion Box", { client_admin_action: "Tile Accepted", tile_id: tile.id }, current_user)
    end

    def ping_tile_ignored(tile)
      ping("Suggestion Box", { client_admin_action: "Tile Ignored", tile_id: tile.id }, current_user)
    end
end
