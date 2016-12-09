class ClientAdmin::CampaignsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  def show
    @board = campaigns.find(params[:id])
    @tiles = @board.tiles.copyable.active.order("activated_at desc")
  end

  private

    def campaigns
      Demo.campaigns
    end
end
