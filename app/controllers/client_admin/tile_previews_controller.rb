# frozen_string_literal: true

# TODO: Rename to SearchTilePreviewsController or merge with ClientAdmin::TilesController#show
class ClientAdmin::TilePreviewsController < ClientAdminBaseController
  prepend_before_action :find_tile

  def show
    ping_tile_viewed
    set_next_prev_tiles

    render json: {
      tilePreview: tile_preview_html
    }
  end

  private

    def find_tile
      begin
        @tile = Tile.find(params[:id])
      rescue
        not_found
      end
    end

    def tile_id
      @tile.id
    end

    def set_next_prev_tiles
      @next_tile = params[:next_tile] || tile_id
      @prev_tile = params[:prev_tile] || tile_id
    end

    def tile_preview_html
      render_to_string(
        formats: [:html],
        partial: "client_admin/tile_previews/tile_preview_modal",
        locals: { tile: @tile, next_tile: @next_tile, prev_tile: @prev_tile }
      )
    end

    def ping_tile_viewed
      ping("Tile - Viewed in Search", { tile_id: @tile.id, type_type: "Client Admin" }, current_user)
    end
end
