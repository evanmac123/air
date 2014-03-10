class ClientAdmin::InactiveTilesController < ClientAdminBaseController
  def index
    @raw_tiles = current_user.demo.archive_tiles.page(params[:page]).per(12)
    @archive_tiles = current_user.demo.add_placeholders @raw_tiles
  end
end
