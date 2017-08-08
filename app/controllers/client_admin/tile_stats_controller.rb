class ClientAdmin::TileStatsController < ClientAdminBaseController
  def index
    tile_stats_report = Reports::TileStatsReport.new(tile_id: params[:tile_id])

    render json: tile_stats_report.data
  end
end
