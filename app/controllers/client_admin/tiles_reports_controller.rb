class ClientAdmin::TilesReportsController < ClientAdminBaseController
  def index
    @active_tiles  = current_user.demo.active_tiles
    @archive_tiles = current_user.demo.archive_tiles
  end
end
