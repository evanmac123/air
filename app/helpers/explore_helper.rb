module ExploreHelper
  # fixed number for explore page
  def tile_batch_size
    16
  end

  def find_tiles
    @eligible_tiles = Tile.viewable_in_public.tagged_with(find_tile_tags)

    @tiles = @eligible_tiles.
      ordered_for_explore.
      offset(offset)
    # @eligible_tiles = Tile.where(true)
    # @tiles = @eligible_tiles.offset(offset)
  end

  def set_all_tiles_displayed
    @all_tiles_displayed = @tiles.count <= tile_batch_size
  end

  def limit_tiles_to_batch_size
    @tiles = @tiles.limit(tile_batch_size)
  end

  def render_partial_if_requested
    return unless params[:partial_only]

    ping("Explore Topic Page", {action: "Clicked See More"}, current_user)

    html_content = render_to_string partial: "explores/tiles", locals: {tiles: @tiles}
    last_batch = @eligible_tiles.count <= offset + tile_batch_size

    render json: {
      htmlContent: html_content,
      lastBatch:   last_batch
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
end
