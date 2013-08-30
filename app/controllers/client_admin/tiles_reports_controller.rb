require 'csv'

class ClientAdmin::TilesReportsController < ClientAdminBaseController

  ReportRow = Struct.new :thumbnail, :headline, :num_completed, :percent_claimed, :status, :activated_at, :archived_at

  def index
    demo = current_user.demo
    num_claimed_users = demo.claimed_user_count

    # Returns a hash of { tile_id: num_completions } => set default value of 0 => "no users have completed this tile"
    num_tile_completions = demo.num_tile_completions
    num_tile_completions.default = 0

    @active_tiles  = []
    @archive_tiles = []

    demo.active_tiles.each do |tile|
      completed_percent = num_tile_completions[tile.id] * 100.0
      @active_tiles << ReportRow.new(tile.thumbnail,
                                     tile.headline,
                                     num_tile_completions[tile.id],
                                     completed_percent / num_claimed_users,
                                     tile.status,
                                     tile.activated_at,
                                     tile.archived_at)
    end

    demo.archive_tiles.each do |tile|
      completed_percent = num_tile_completions[tile.id] * 100.0
      @archive_tiles << ReportRow.new(tile.thumbnail,
                                      tile.headline,
                                      num_tile_completions[tile.id],
                                      completed_percent / num_claimed_users,
                                      tile.status,
                                      tile.activated_at,
                                      tile.archived_at)

    end

    respond_to do |format|
      format.html

      format.csv do
        @tiles = params[:report] == Tile::ACTIVE ? @active_tiles : @archive_tiles
        set_csv_filename
        render content_type: "text/csv"
      end
    end
  end

  private

  def set_csv_filename
    response.headers['Content-Disposition'] = "attachment; filename=#{params[:report]}_tiles_report_#{Time.zone.now.to_s(:csv_file_date_stamp)}.csv"
  end
end
