class ClientAdmin::TileStatsController < ClientAdminBaseController
  def index
    tile_stats_report = Reports::TileStatsReport.new(tile_id: params[:tile_id])

    render json: tile_stats_report.data
  end

  def download_report
    tile_stats_report = Reports::TileStatsDownloadReport.new(tile_id: params[:tile_id])

    send_data(tile_stats_report.data, type: "application/xlsx", filename: tile_stats_report.filename)
  end
end
