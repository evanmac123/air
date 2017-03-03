module ClientAdmin::TilesPingsHelper
  def record_index_ping
    ping_page('Manage - Tiles', current_user)
    if params[:show_suggestion_box].present?
      ping('Suggestion Box', {client_admin_action: "Suggestion Box Opened"}, current_user)
    end
  end

  def tile_status_updated_ping tile, action
    ping('Moved Tile in Manage', {action: action, tile_id: tile.id}, current_user)
  end

  def tile_in_box_updated_ping tile
    if tile.status == Tile::DRAFT
      ping('Suggestion Box', {client_admin_action: "Tile Accepted", tile_id: tile.id}, current_user)
    elsif tile.status == Tile::IGNORED
      ping('Suggestion Box', {client_admin_action: "Tile Ignored", tile_id: tile.id}, current_user)
    end
  end

  def destroy_tile_ping(page)
    ping('Tile - Deleted', { page: page, "Current URL" => request.referrer }, current_user)
  end

  def schedule_tile_creation_ping(tile, source)
    ping('Tile - New', tile_creation_ping_props(tile, source), current_user)
  end

  def tile_in_box_viewed_ping tile
    return unless tile.suggested?
    ping('Suggestion Box', {client_admin_action: "Tile Viewed", tile_id: tile.id}, current_user)
  end

  def tile_creation_ping_props tile, source
    {
      tile_source: source,
      is_public: tile.is_public,
      tag: tile.tile_tags.first.try(:title)
    }
  end

end
