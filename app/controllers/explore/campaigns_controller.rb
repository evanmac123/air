class Explore::CampaignsController < ExploreBaseController
  def show
    @campaign = Campaign.find_by_slug(params[:id])
    @tiles = @campaign.tiles.ordered_by_position.explore_non_ordered.active
    @display_channels = Channel.display_channels
  end
end
