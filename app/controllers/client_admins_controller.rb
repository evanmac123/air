class ClientAdminsController < ClientAdminBaseController

  def show
    @board = Tile.first
    @tst_board = Demo.find(9)
    @chart_form = BoardStatsLineChartForm.new @board, {action_type: params[:action_type]}

    @chart = BoardStatsChart.new(@chart_form.period, @chart_form.plot_data).draw

    grid_builder = BoardStatsGrid.new(@tst_board)
    @board_stats_grid = initialize_grid(*grid_builder.args)
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
