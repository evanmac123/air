class ClientAdmin::TilePreviewsController < ClientAdminBaseController
  prepend_before_filter :find_tile

  def show
    if params[:from_search]
      ping("Tile - Viewed in Search", { tile_id: @tile.id, type_type: "Client Admin" }, current_user)
    end

    @next_tile = params[:next_tile] || @tile.id
    @prev_tile = params[:prev_tile] || @tile.id

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
