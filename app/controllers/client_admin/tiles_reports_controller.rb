# frozen_string_literal: true

require "csv"

class ClientAdmin::TilesReportsController < ClientAdminBaseController
  def show
    num_tile_completions = current_board.num_tile_completions
    num_tile_completions.default = 0

    respond_to do |format|
      format.csv do
        @tiles = report_tiles
        set_csv_filename
        render content_type: "text/csv"
      end
    end
  end

  private

    def set_csv_filename
      response.headers["Content-Disposition"] = "attachment; filename=#{params[:report]}_tiles_report_#{Time.zone.now.to_s(:csv_file_date_stamp)}.csv"
    end

    def report_tiles
      if params[:report] == Tile::ACTIVE
        current_board.active_tiles
      else
        current_board.archive_tiles
      end
    end
end
