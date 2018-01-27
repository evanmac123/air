# frozen_string_literal: true

class Api::ClientAdmin::Tile::SortsController < Api::ClientAdminBaseController
  def create
    @tile = current_user.demo.tiles.find_by(id: params[:tile_id])
    Tile::Sorter.call(tile: @tile, params: sort_params)

    render json: {
      tileId: @tile.id,
      tilesToBeSentCount: demo.digest_tiles_count,
      tileHTML: tile_html
    }
  end

  private

    def demo
      current_user.demo
    end

    def sort_params
      params.require(:sort).permit(:left_tile_id, :new_status, :redigest)
    end

    def tile_presenter(tile)
      @presenter ||= present(tile, SingleAdminTilePresenter, is_ie: browser.ie?, from_search: params[:from_search])
    end

    def tile_html
      render_to_string(
        formats: [:html],
        partial: "client_admin/tiles/manage_tiles/single_tile",
        locals: { presenter:  tile_presenter(@tile) }
      )
    end
end
