module ExploreHelper
  # fixed number for explore page
  def tile_batch_size
    12
  end

  def find_tiles
    @explore_tiles ||= Tile.copyable.tagged_with(find_tile_tags)

    set_recommended_tiles
    set_verified_tiles
    set_community_tiles
  end

  def set_recommended_tiles
    @recommended_tiles ||= @explore_tiles.
      limit(6)
  end

  def set_verified_tiles
    @verified_tiles ||= @explore_tiles.
      ordered_for_explore.
      offset(offset).
      limit(tile_batch_size)

    @all_verified_tiles = @verified_tiles.count <= tile_batch_size
  end

  def set_community_tiles
    @community_tiles ||= @explore_tiles.
      ordered_for_explore.
      offset(offset).
      limit(tile_batch_size).reverse

    @all_community_tiles = @community_tiles.count <= tile_batch_size
  end

  def render_partial_if_requested
    return unless params[:partial_only]

    @explore_tiles ||= Tile.copyable.tagged_with(find_tile_tags)

    if params[:tile_type] == "verified-explore"
      @more_tiles = @verified_tiles
      @last_batch = @all_verified_tiles
    elsif params[:tile_type] == "community-explore"
      @more_tiles = @community_tiles
      @last_batch = @all_community_tiles
    end

    html_content = render_to_string partial: "explores/tiles", locals: {tiles: @more_tiles}

    render json: {
      htmlContent: html_content,
      lastBatch:   @last_batch
    }
  end

  def offset
    @_offset = params[:offset].present? ? params[:offset].to_i : 0
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
end
