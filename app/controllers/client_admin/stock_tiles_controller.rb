class ClientAdmin::StockTilesController < ClientAdminBaseController

  def show
    @current_user = current_user
    @tile = Tile.find(params[:id])
    @demo = @tile.demo
    @prev, @next = @demo.bracket @tile
   
    @current_tile_ids = @demo.tiles.active.order("activated_at desc").map(&:id)
  end


end
