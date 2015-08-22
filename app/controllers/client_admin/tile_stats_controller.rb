class ClientAdmin::TileStatsController < ClientAdminBaseController
  def index
    @tile = Tile.find(params[:tile_id])
    @chart_form = TileStatsChartForm.new @tile
    @chart = TileStatsChart.new(@tile, @chart_form.chart_params).draw
    @tile_completions = TileCompletion.tile_completions_with_users(@tile.id)
  end
end
