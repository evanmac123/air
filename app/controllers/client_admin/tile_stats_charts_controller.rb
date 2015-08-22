class ClientAdmin::TileStatsChartsController < ClientAdminBaseController
  def create
    @tile = Tile.find(params[:tile_id])
    @chart_form = TileStatsChartForm.new @tile, params[:tile_stats_chart_form]
    @chart = TileStatsChart.new(@tile, @chart_form.chart_params).draw
    @tile_completions = TileCompletion.tile_completions_with_users(@tile.id)
    render 'client_admin/tile_stats/index'
  end
end
