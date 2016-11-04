module ExploreHelper
  def tile_batch_size
    12
  end

  def collection_batch_size
    4
  end

  def find_tiles_and_collections
    @explore_tiles ||= Tile.copyable

    set_collections
    set_recommended_tiles
    set_verified_tiles
    set_community_tiles
  end

  def set_collections
    collections = collection_boards.offset(collection_offset)
    @all_collections = collections.count <= collection_batch_size
    @collections = collections.limit(collection_batch_size)
  end

  def set_recommended_tiles
    @recommended_tiles = @explore_tiles.
      verified_explore.
      recommended.limit(6)
  end

  def set_verified_tiles
    @all_verified_tiles = @explore_tiles.verified_explore

    batched_verified_tiles = @all_verified_tiles.
      ordered_for_explore.
      offset(offset)

    @all_verified_tiles_displayed = batched_verified_tiles.count <= tile_batch_size
    @verified_tiles = batched_verified_tiles.limit(tile_batch_size)
  end

  def set_community_tiles
    @all_community_tiles = @explore_tiles.community_explore

    batched_community_tiles = @all_community_tiles.
      ordered_for_explore.
      offset(offset)

    @all_community_tiles_displayed = batched_community_tiles.count <= tile_batch_size
    @community_tiles = batched_community_tiles.limit(tile_batch_size)
  end

  def render_partial_if_requested
    return unless params[:partial_only]

    if params[:content_type] == "collection"
      render_collections_partial
    else
      render_tiles_partial
    end
  end

  def render_tiles_partial
    if params[:content_type] == "verified-explore"
      @all_tiles  = @all_verified_tiles
      @more_tiles = @verified_tiles
      @last_batch = @all_verified_tiles_displayed
    elsif params[:content_type] == "community-explore"
      @all_tiles  = @all_community_tiles
      @more_tiles = @community_tiles
      @last_batch = @all_community_tiles_displayed
    end

    html_content = render_to_string partial: "explores/tiles", locals: { tiles: @more_tiles, tile_ids: @all_tiles.pluck(:id) }

    render json: {
      htmlContent: html_content,
      lastBatch:   @last_batch,
      objectCount: @more_tiles.count
    }
  end

  def render_collections_partial
    @more_collections = @collections
    @last_batch = @all_collections

    html_content = render_to_string partial: "explores/collection_block", locals: { collections: @more_collections }

    render json: {
      htmlContent: html_content,
      lastBatch:   @last_batch,
      objectCount: @more_collections.count
    }
  end

  def offset
    @_offset = params[:tile_offset].present? ? params[:tile_offset].to_i : 0
  end

  def collection_offset
    @_collection_offset = params[:collection_offset].present? ? params[:collection_offset].to_i : 0
  end

  def new_user?
    Time.now - current_user.accepted_invitation_at < 1.minute
  end

  def explore_intro_ping show, params
    return unless show
    source = if params[:explore_token].present?
      "Tiles Email"
    else
      new_user? ? "New User" : "Existing User"
    end
    ping "Explore Onboarding", {"Source" => source}, current_user
  end

  def explore_content_link_ping
    if params[:explore_content_link]
      ping "Explore page - Interaction", {"action" => 'Clicked "Explore more great content"'}, current_user
    end
  end

  def find_tile_tags
   params[:tile_tag]
  end

  def collection_boards
    Demo.includes(topic_board: :topic).where(topic_board: { is_library: true } )
  end

  def toggle_recommend tile
    tile.recommended? ? unrecommend_link(tile) : recommend_link(tile)
  end

  def unrecommend_link tile
    link_to "Unrecommend",  admin_recommended_tile_path(tile), method: :delete
  end

  def recommend_link tile
    link_to "Recommend",  admin_recommended_tiles_path(tile)
  end
end
