class ClientAdmin::TileStatsController < ClientAdminBaseController
  def index
    @tile = Tile.find(params[:tile_id])

    @chart_form = TileStatsChartForm.new @tile
    @chart = TileStatsChart.new(*@chart_form.chart_params).draw

    @survey_chart = @tile.survey_chart if @tile.is_survey?

    @grid_type = GridQuery::TileActions::GRID_TYPES.keys.first
    @tile_stats_grid = initialize_grid *TileStatsGrid.new(@tile, @grid_type).args
  end
end
