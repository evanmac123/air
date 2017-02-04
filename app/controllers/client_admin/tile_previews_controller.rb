class ClientAdmin::TilePreviewsController < ClientAdminBaseController
  prepend_before_filter :find_tile

  def show
    @tiles = params[:tile_ids] ? get_sorted_tiles : [@tile]
    @next_tile = next_tile(1)
    @prev_tile = next_tile(-1)

    render partial: "client_admin/tile_previews/tile_preview_modal",
           locals: { tile: @tile, tag: @tag, next_tile: @next_tile, prev_tile: @prev_tile },
           layout: false
  end

  private

    def get_sorted_tiles
      ids = params[:tile_ids].map(&:to_i)
      default_sorting = Tile.where(id: ids).group_by(&:id)
      ids.map { |id| default_sorting[id].first }
    end

    def find_tile
      begin
        @tile ||= Tile.find(params[:id])
      rescue
        not_found
      end
    end

    def next_tile(offset)
      next_tile = @tiles[@tiles.index(@tile).to_i + offset] || @tiles.first
      next_tile || @tile
    end
end
