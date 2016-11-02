module ExploreHelper
  def tile_batch_size
    12
  end

  def campaign_batch_size
    4
  end

  def find_tiles_and_campaigns
    @explore_tiles ||= Tile.copyable.tagged_with(find_tile_tags)

    set_campaigns
    set_recommended_tiles
    set_verified_tiles
    set_community_tiles
  end

  def set_campaigns
    campaigns = campaign_boards.offset(campaign_offset)
    @all_campaigns = campaigns.count <= campaign_batch_size
    @campaigns = campaigns.limit(campaign_batch_size)
  end

  def set_recommended_tiles
    @recommended_tiles ||= @explore_tiles.
      limit(6)
  end

  def set_verified_tiles
    verified_tiles ||= @explore_tiles.
      ordered_for_explore.
      offset(offset)

    @all_verified_tiles = verified_tiles.count <= tile_batch_size
    @verified_tiles = verified_tiles.limit(tile_batch_size)
  end

  def set_community_tiles
    community_tiles ||= @explore_tiles.
      ordered_for_explore.
      offset(offset)

    @all_community_tiles = community_tiles.count <= tile_batch_size

    @community_tiles = community_tiles.limit(tile_batch_size)
  end

  def render_partial_if_requested
    return unless params[:partial_only]

    if params[:content_type] == "campaign"
      render_campaigns_partial
    else
      render_tiles_partial
    end
  end

  def render_tiles_partial
    if params[:content_type] == "verified-explore"
      @more_tiles = @verified_tiles
      @last_batch = @all_verified_tiles
    elsif params[:content_type] == "community-explore"
      @more_tiles = @community_tiles
      @last_batch = @all_community_tiles
    end

    html_content = render_to_string partial: "explores/tiles", locals: {tiles: @more_tiles}

    render json: {
      htmlContent: html_content,
      lastBatch:   @last_batch
    }
  end

  def render_campaigns_partial
    @more_campaigns = @campaigns
    @last_batch = @all_campaigns

    html_content = render_to_string partial: "explores/campaign_block", locals: { campaigns: @more_campaigns }

    render json: {
      htmlContent: html_content,
      lastBatch:   @last_batch
    }
  end

  def offset
    @_offset = params[:tile_offset].present? ? params[:tile_offset].to_i : 0
  end

  def campaign_offset
    @_campaign_offset = params[:campaign_offset].present? ? params[:campaign_offset].to_i : 0
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

  def campaign_boards
    Demo.includes(topic_board: :topic).where(topic_board: { is_library: true } )
  end
end
