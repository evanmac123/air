class ClientAdmin::ReportsController < ClientAdminBaseController

  def show
   @demo = current_user.demo
   @report = Reporting::ClientUsage.new({demo:@demo.id, start: 12.weeks.ago, interval: "week"})
   binding.pry
  end

  def temporary_create
    @tile = Tile.first
    binding.pry
    @chart_form = DemoStatsChartForm.new @tile, params[:demo_stats_chart_form]
    @chart = DemoStatsChart.new(@chart_form.period, @chart_form.data).draw
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
