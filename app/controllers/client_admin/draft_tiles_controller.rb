class ClientAdmin::DraftTilesController < ClientAdminBaseController
  def index
    @draft_tiles = current_user.demo.draft_tiles_with_placeholders
  end
end
