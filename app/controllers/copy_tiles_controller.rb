class CopyTilesController < ClientAdminBaseController
  skip_before_filter :authorize

  def create
    tile = Tile.copyable.where(id: params[:tile_id]).first
    copy = tile.copy_to_new_demo(current_user.demo)
    render json: {success: true, editTilePath: edit_client_admin_tile_path(copy)}
  end
end
