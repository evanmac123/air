class ClientAdmin::TileStatsController < ClientAdminBaseController
  def index
    @tile = Tile.find(params[:tile_id])

    @chart_form = TileStatsChartForm.new @tile
    @chart = TileStatsChart.new(*@chart_form.chart_params).draw

    @survey_chart = @tile.survey_chart if @tile.is_survey?

    # @grid_type = GridQuery::TileActions::GRID_TYPES.keys.first
    grid_builder = TileStatsGrid.new(@tile, nil)
    @tile_stats_grid = initialize_grid *grid_builder.args
    @current_grid = grid_builder.query_type

    respond_to do |format|
      format.html
      format.json do
        render json: { page: page_to_string }
      end
    end
  end

  protected
    def page_to_string
      render_to_string(
        'index',
        formats: [:html],
        layout: false
      )
    end
end
