class ClientAdmin::TileStatsController < ClientAdminBaseController
  def index
    @tile = Tile.find(params[:tile_id])

    @chart_form = TileStatsChartForm.new @tile
    @chart = TileStatsChart.new(*@chart_form.chart_params).draw

    @tile_stats_grid = initialize_grid *TileStatsGrid.new(@tile).args
  end
end
