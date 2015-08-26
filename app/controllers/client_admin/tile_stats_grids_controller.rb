class ClientAdmin::TileStatsGridsController < ClientAdminBaseController
  def index
    @tile = Tile.find(params[:tile_id])
    @tile_stats_grid = initialize_grid *TileStatsGrid.new(@tile, params["grid_type"]).args

    render json: { grid: grid_to_string, success: true }
  end

  protected
    def grid_to_string
      render_to_string(
        partial: 'grid_section',
        formats: [:html],
        locals: {
          tile: @tile,
          tile_stats_grid: @tile_stats_grid
        }
      )
    end
end
