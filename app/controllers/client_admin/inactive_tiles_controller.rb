class ClientAdmin::InactiveTilesController < ClientAdminBaseController
  def index
    @archive_tiles = current_user.demo.archive_tiles_with_placeholders
  end
end
