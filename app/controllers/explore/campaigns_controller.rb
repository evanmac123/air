class Explore::CampaignsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  def show
    @board = campaigns.find(params[:id])
    @tiles = @board.tiles.explore.active.order("activated_at desc")
    @display_channels = Channel.display_channels()
  end

  private

    def campaigns
      Demo.campaigns
    end
end
