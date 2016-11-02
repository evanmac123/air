class ClientAdmin::CampaignsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  def show
    @board = campaign_boards.find(params[:id])
    @tiles = @board.tiles.copyable.active.order("activated_at desc")
  end

  def index
    @boards = campaign_boards
  end

  private

    def campaign_boards
      Demo.joins(:topic_board).where(topic_board: { is_library: true } )
    end
end
