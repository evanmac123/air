class ClientAdmin::ReportsController < ClientAdminBaseController

  def show
    @demo = current_user.demo
    @chart_form = BoardStatsLineChartForm.new @demo, {action_type: params[:action_type]}
    @chart = BoardStatsChart.new(@chart_form.period, @chart_form.plot_data).draw
  end

  def temporary_create
    @board = Tile.first
    @chart_form = BoardStatsLineChartForm.new @board, params[:board_stats_line_chart_form]
    @chart = BoardStatsChart.new(@chart_form.period, @chart_form.plot_data).draw
    render json: { chart: chart_to_string, success: true}
    # @demo = current_user.demo
    # @chart_form = BoardStatsLineChartForm.new @demo, {action_type: params[:action_type]}
    # @chart = BoardStatsChart.new(@chart_form.period, @chart_form.plot_data).draw
  end

  private
    def chart_to_string
      render_to_string(
        partial: 'client_admin/activity/activity_charts',
        formats: [:html],
        locals: {
          chart_form: @chart_form,
          chart: @chart
        }
      )
    end
end
