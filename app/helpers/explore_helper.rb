module ExploreHelper
  def tile_batch_size
    12
  end

  def campaign_batch_size
    4
  end

  def find_tiles_and_campaigns
    @explore_tiles ||= Tile.explore

    set_campaigns
    set_verified_tiles
    set_community_tiles
  end

  def set_campaigns
    campaigns = campaign_boards.offset(campaign_offset)
    @all_campaigns = campaigns.count <= campaign_batch_size
    @campaigns = campaigns.limit(campaign_batch_size)
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

    if params[:content_type] == "campaign"
      render_campaigns_partial
    else
      render_tiles_partial
    end
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

  def render_campaigns_partial
    @more_campaigns = @campaigns
    @last_batch = @all_campaigns

    html_content = render_to_string partial: "explore/campaign_block", locals: { campaigns: @more_campaigns }

    render json: {
      htmlContent: html_content,
      lastBatch:   @last_batch,
      objectCount: @more_campaigns.count
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

  def campaign_boards
    # TODO: NEXT RELEASE: change to Demo.includes(:campaign).where(campaign: { active: true })  (add as campaigns scope on Demo)
    Demo.includes(topic_board: :topic).where(topic_board: { is_library: true } )
  end
end
