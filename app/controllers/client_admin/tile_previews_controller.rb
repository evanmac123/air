class ClientAdmin::TilePreviewsController < ClientAdminBaseController
  prepend_before_filter :find_tile

  def show
    render partial: "client_admin/tile_previews/tile_preview_modal",
           locals: { tile: @tile, tag: @tag, next_tile: @next_tile, prev_tile: @prev_tile },
           layout: false
  end

  private

    def find_tile
      begin
        @tile ||= Tile.find(params[:id])
      rescue
        not_found
      end
    end
end
