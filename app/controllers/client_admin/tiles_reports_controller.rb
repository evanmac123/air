# frozen_string_literal: true

require "csv"

class ClientAdmin::TilesReportsController < ClientAdminBaseController
  def show
    @tiles = report_tiles

    respond_to do |format|
      format.csv do
        headers["Content-Type"] ||= "text/csv; charset=UTF-8; header=present"
        headers["Content-Disposition"] = "attachment; filename=#{params[:report]}_tiles_report_#{Time.zone.now.to_s(:csv_file_date_stamp)}.csv"
      end
    end
  end

  private

    def report_tiles
      if params[:report] == Tile::ACTIVE
        current_board.active_tiles.ordered_by_position
      else
        current_board.archive_tiles.ordered_by_position
      end
    end
end
