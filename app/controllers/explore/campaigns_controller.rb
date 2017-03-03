class Explore::CampaignsController < ExploreBaseController
  def show
    @campaign = find_campaign
    @tiles = @campaign.tiles.ordered_by_position.explore_non_ordered.active
    @display_channels = Channel.display_channels
  end

  private

    def find_campaign
      Campaign.find(params[:id].to_i)
    end
end
