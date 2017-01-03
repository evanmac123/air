module ExploreHelper
  def tile_batch_size
    12
  end

  def find_tiles_and_campaigns
    @explore_tiles ||= Tile.explore

    @campaigns = Campaign.all
    set_verified_tiles
    set_community_tiles
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
    render_tiles_partial
  end

  def render_tiles_partial
    if params[:content_type] == "verified-explore"
      @more_tiles = @verified_tiles
      @last_batch = @all_verified_tiles_displayed
      @section = "Airbo Tile"
    elsif params[:content_type] == "community-explore"
      @more_tiles = @community_tiles
      @last_batch = @all_community_tiles_displayed
      @section = "Community Tile"
    end

    html_content = render_to_string partial: "explore/tiles", locals: { tiles: @more_tiles, section: @section }

    render json: {
      htmlContent: html_content,
      lastBatch:   @last_batch,
      objectCount: @more_tiles.count,
    }
  end

  def offset
    @_offset = params[:tile_offset].present? ? params[:tile_offset].to_i : 0
  end
end
