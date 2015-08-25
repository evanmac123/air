class ClientAdmin::TileStatsChartsController < ClientAdminBaseController
  def create
    @tile = Tile.find(params[:tile_id])
    @chart_form = TileStatsChartForm.new @tile, params[:tile_stats_chart_form]
    @chart = TileStatsChart.new(*@chart_form.chart_params).draw
    @tile_completions = TileCompletion.tile_completions_with_users(@tile.id)
    respond_to do |format|
      format.html { render 'client_admin/tile_stats/index' }
      format.json { render json: { chart: chart_to_string, success: true } }
    end
  end

  protected
    def chart_to_string
      chart_to_string = render_to_string(
        partial: 'chart_section',
        formats: [:html],
        locals: {
          chart_form: @chart_form,
          chart: @chart
        }
      )
    end
end
