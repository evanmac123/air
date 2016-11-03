class ClientAdmin::CollectionsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  def show
    @board = collection_boards.find(params[:id])
    @tiles = @board.tiles.copyable.active.order("activated_at desc")
  end

  def index
    @boards = collection_boards
  end

  private

    def collection_boards
      Demo.joins(:topic_board).where(topic_board: { is_library: true } )
    end
end
