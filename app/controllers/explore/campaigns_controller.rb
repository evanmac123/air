class Explore::CampaignsController < ExploreBaseController
  def show
    @campaign = Campaign.find_by_slug(params[:id])
    @tiles = @campaign.tiles.explore.active.order("activated_at desc")
    @display_channels = Channel.display_channels
  end
end
