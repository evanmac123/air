class ClientAdmin::StockBoardsController < ClientAdminBaseController
  include TileBatchHelper
  def index
     sort_demos

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

 def board_slugs
   @slugs ||= HOMEPAGE_BOARD_SLUGS.split(",")
 end


 def sort_demos
   @demos = Demo.where(public_slug:board_slugs)
   @sorted_demos = board_slugs.map do|slug|
     @demos.where(public_slug: slug).first
   end.compact
 end


end
