module ClientAdmin::TilesPingsHelper
  def record_index_ping
    ping_page('Manage - Tiles', current_user)
    if params[:show_suggestion_box].present?
      ping('Suggestion Box', {client_admin_action: "Suggestion Box Opened"}, current_user)
    end
  end

  def record_new_ping
    ping('Tiles Page', {action: 'Clicked Add New Tile'}, current_user)
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
    ping('Tile - Deleted', {page: page}, current_user)
  end

  def schedule_tile_creation_ping(tile)
    ping('Tile - New', {tile_source: "Self Created", is_public: tile.is_public, is_copyable: tile.is_copyable, tag: tile.tile_tags.first.try(:title)}, current_user)
  end

  def tile_in_box_viewed_ping tile
    return unless tile.suggested?
    ping('Suggestion Box', {client_admin_action: "Tile Viewed", tile_id: tile.id}, current_user)
  end
end
