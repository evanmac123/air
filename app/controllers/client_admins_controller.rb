class ClientAdminsController < ClientAdminBaseController

  def show
    @tile = Tile.first
    @chart_form = DemoStatsChartForm.new @tile, {action_type: params[:action_type]}

    @chart = DemoStatsChart.new(@chart_form.period, @chart_form.data).draw

    grid_builder = TileStatsGrid.new(@tile)
    @tile_stats_grid = initialize_grid(*(grid_builder.args))
    @current_grid = grid_builder.query_type
    render template: "client_admin/show"
  end

  private
    def page_to_string
      render_to_string(
        'client_admin/show',
        formats: [:html],
        layout: false
      )
    end
end
