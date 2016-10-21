class ClientAdmin::StockBoardsController < ClientAdminBaseController
  include TileBatchHelper
  def index
    @boards = library_boards
  end

  def show
    @current_user = current_user
    @demo = Demo.public_board_by_public_slug(params[:library_slug])
    @tiles = @demo.tiles.active.order("activated_at desc").limit(max_tiles)
    @show_more_tiles = true
    if request.xhr?
      render :partial => "stock_board_wall", :layout => false and return
    end
  end

  private

    def max_tiles
      curr_page * 16
    end

    def curr_page
      @page ||= params[:page].try(:to_i) || 1
    end

    def library_boards
      Demo.joins(:topic_board).where(topic_board: { is_library: true } )
    end
end
