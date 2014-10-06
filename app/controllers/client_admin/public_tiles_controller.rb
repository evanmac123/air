class ClientAdmin::PublicTilesController < ClientAdminBaseController
  before_filter :get_tile

  def update
    @tile.update_attributes params[:multiple_choice_tile]
    render nothing: true
  end

  protected

  def get_tile
    @tile = current_user.demo.tiles.find params[:id]
  end
end