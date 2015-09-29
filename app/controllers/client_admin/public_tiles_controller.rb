#FIXME delete this controller and refactor functionality back into TilePublicForm
class ClientAdmin::PublicTilesController < ClientAdminBaseController
  before_filter :get_tile

  def update
    TilePublicForm.new(@tile, params[:tile_public_form]).save
    render nothing: true
  end

  protected

  def get_tile
    @tile = current_user.demo.tiles.find params[:id]
  end
end
