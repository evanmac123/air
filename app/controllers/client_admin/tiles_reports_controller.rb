class ClientAdmin::TilesReportsController < ClientAdminBaseController
  def index
    demo = current_user.demo

    @active_tiles  = demo.active_tiles
    @archive_tiles = demo.archive_tiles
  end
end
