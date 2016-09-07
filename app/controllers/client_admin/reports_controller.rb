class ClientAdmin::ReportsController < ClientAdminBaseController

  def show
    @demo = current_user.demo
    @chart_form = BoardStatsLineChartForm.new @demo, {action_type: params[:action_type]}
    @chart = BoardStatsChart.new(@chart_form.period, @chart_form.plot_data).draw
  end

end
