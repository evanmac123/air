module ClientAdmin::TilesPingsHelper
  def record_index_ping
    if param_path == :via_draft_preview
      TrackEvent.ping_action('Tile Preview Page - Draft', 'Clicked Back to Tiles button', current_user)
    elsif param_path == :via_posted_preview
      TrackEvent.ping_action('Tile Preview Page - Posted', 'Clicked Back to Tiles button', current_user)      
    elsif param_path == :via_archived_preview
      TrackEvent.ping_action('Tile Preview Page - Archive', 'Clicked Back to Tiles button', current_user)      
    end

    ping_page('Manage - Tiles', current_user)
  end

  def record_new_ping
    if param_path == :via_index
      TrackEvent.ping_action('Tiles Page', 'Clicked Add New Tile', current_user)
    elsif param_path == :via_draft_preview
      TrackEvent.ping_action('Tile Preview Page - Draft', 'Clicked New Tile button', current_user)    
    elsif param_path == :via_posted_preview
      TrackEvent.ping_action('Tile Preview Page - Posted', 'Clicked New Tile button', current_user)    
    elsif param_path == :via_archived_preview
      TrackEvent.ping_action('Tile Preview Page - Archive', 'Clicked New Tile button', current_user)    
    end
  end

  def record_update_status_ping
    if param_path == :via_preview_draft
      TrackEvent.ping_action('Tile Preview Page - Draft', 'Clicked Post button', current_user)
    elsif param_path == :via_preview_post
      TrackEvent.ping_action('Tile Preview Page - Posted', 'Clicked Archive button', current_user)
    elsif param_path == :via_preview_archive
      TrackEvent.ping_action('Tile Preview Page - Archive', 'Clicked Re-post button', current_user)
    elsif param_path == :via_index
      TrackEvent.ping_action('Tiles Page', 'Clicked Post to activate tile', current_user)
    end
  end

  def record_edit_ping
    if param_path == :via_draft_preview
      TrackEvent.ping_action('Tile Preview Page - Draft', 'Clicked Edit button', current_user)
    elsif param_path == :via_posted_preview
      TrackEvent.ping_action('Tile Preview Page - Posted', 'Clicked Edit button', current_user)      
    elsif param_path == :via_archived_preview
      TrackEvent.ping_action('Tile Preview Page - Archive', 'Clicked Edit button', current_user)      
    end
  end

  def tile_status_updated_ping tile, action
    ping('Moved Tile in Manage', {action: action, tile_id: tile.id}, current_user)
  end

  def destroy_tile_ping(page)
    ping('Tile - Deleted', {page: page}, current_user)
  end

  def schedule_tile_creation_ping(tile)
    ping('Tile - New', {tile_source: "Self Created", is_public: tile.is_public, is_copyable: tile.is_copyable, tag: tile.tile_tags.first.try(:title)}, current_user)
  end
end    