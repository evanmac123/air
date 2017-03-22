class ClientAdminsController < ClientAdminBaseController

  def show
    @board = current_user.demo
    @chart_form = BoardStatsLineChartForm.new @board, { action_type: params[:action_type] }

    grid_builder = BoardStatsGrid.new(@board)
    @board_stats_grid = initialize_grid(*grid_builder.args)
    @current_grid = grid_builder.query_type

    render template: "client_admin/show"
  end
end
