class ClientAdmin::ReportsController < ClientAdminBaseController
  skip_before_filter :authorize

  def show
    @demo = current_user.demo
    @chart_form = BoardStatsLineChartForm.new @demo, {action_type: params[:action_type]}
    @chart = BoardStatsChart.new(@chart_form.period, @chart_form.plot_data, "#fff").draw
  end

  def temporary_create
     @demo = current_user.demo
     @chart_form = BoardStatsLineChartForm.new(@demo,  params[:board_stats_line_chart_form])
     @chart = BoardStatsChart.new(@chart_form.period, @chart_form.plot_data, "#fff").draw

    render json: { chart: chart_to_string, success: true}
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