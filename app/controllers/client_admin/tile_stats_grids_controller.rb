class ClientAdmin::TileStatsGridsController < ClientAdminBaseController
  def index
    @tile = Tile.find(params[:tile_id])
    @tile_stats_grid = initialize_grid *TileStatsGrid.new(@tile, params["grid_type"]).args

    export_grid_if_requested('tile_stats_grid' => 'grid') do
      # if the request is not a CSV export request
      render json: { grid: grid_to_string, success: true }
    end
  end

  protected
    def grid_to_string
      render_to_string(
        partial: 'grid_section',
        formats: [:html],
        locals: {
          tile: @tile,
          tile_stats_grid: @tile_stats_grid,
          current_grid: params["grid_type"]
        }
      )
    end
end
