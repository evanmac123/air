class ClientAdmin::TileStatsController < ClientAdminBaseController
  before_filter :find_tile_and_demo

  def index
    @tile_completions = TileCompletion.tile_completions_with_users(@tile.id)
    @chart = TileStatsChart.new(@tile).draw
    # params[:chart_start_date]   = (Time.now - 30.days).to_s(:chart_start_end_day)
    # params[:chart_end_date]     = Time.now.to_s(:chart_start_end_day)
    # params[:chart_plot_content] = 'Both'
    # params[:chart_interval]     = 'Weekly'
    # params[:chart_label_points] = '0'
    # @chart = Highchart.chart current_user.demo,
    #                          params[:chart_start_date],
    #                          params[:chart_end_date],
    #                          params[:chart_plot_content],
    #                          params[:chart_interval],
    #                          params[:chart_label_points]
  end

  protected

  def find_tile_and_demo
    @tile = Tile.find(params[:tile_id])
    unless current_user && current_user.in_board?(@tile.demo_id)
      not_found
      return false
    end

    @demo = @tile.demo
  end
end
