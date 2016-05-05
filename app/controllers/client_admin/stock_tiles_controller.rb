class ClientAdmin::StockTilesController < ClientAdminBaseController

  def show
    @current_user = current_user
    @tile = Tile.find(params[:id])

    @prev, @next = @tile.demo.bracket @tile
  end


end
