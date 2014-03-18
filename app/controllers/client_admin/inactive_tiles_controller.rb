class ClientAdmin::InactiveTilesController < ClientAdminBaseController
  PER_PAGE = 12.freeze
  def index
    @demo = current_user.demo
    @raw_tiles = current_user.demo.archive_tiles.page(params[:page]).per(PER_PAGE)
    @archive_tiles = current_user.demo.add_placeholders @raw_tiles
  end
end
