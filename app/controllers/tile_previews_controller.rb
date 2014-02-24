class TilePreviewsController < ClientAdminBaseController
  def show
    @tile = Tile.viewable_in_public.where(id: params[:id]).first
  end
end
