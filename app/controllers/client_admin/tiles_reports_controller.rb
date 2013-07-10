class ClientAdmin::TilesReportsController < ClientAdminBaseController

  ReportRow = Struct.new :thumbnail, :headline, :num_completed, :percent_claimed, :percent_all

  def index
    demo = current_user.demo

    num_all_users     = demo.users.count
    num_claimed_users = demo.claimed_user_count

    # todo move this to the model and spec it
    num_tile_completions = demo.tile_completions.group(:tile_id).count
    num_tile_completions.default = 0

    @active_tiles  = []
    @archive_tiles = []

    demo.active_tiles.each do |tile|
      num_completed = TileCompletion.where(tile_id: tile.id).count.to_f
      @active_tiles << ReportRow.new(tile.thumbnail,
                                     tile.headline,
                                     num_completed,
                                     (num_completed / num_claimed_users) * 100,
                                     (num_completed / num_all_users) * 100)

      #completed_percent = num_tile_completions[tile.id] * 100.0
      #@active_tiles << ReportRow.new(tile.thumbnail,
      #                               tile.headline,
      #                               num_tile_completions[tile.id],
      #                               completed_percent / num_claimed_users,
      #                               completed_percent / num_all_users)
    end

    demo.archive_tiles.each do |tile|
      num_completed = TileCompletion.where(tile_id: tile.id).count.to_f
      @archive_tiles << ReportRow.new(tile.thumbnail,
                                      tile.headline,
                                      num_completed,
                                      (num_completed / num_claimed_users) * 100,
                                      (num_completed / num_all_users) * 100)

      #completed_percent = num_tile_completions[tile.id] * 100.0
      #@archive_tiles << ReportRow.new(tile.thumbnail,
      #                                tile.headline,
      #                                num_tile_completions[tile.id],
      #                                completed_percent / num_claimed_users,
      #                                completed_percent / num_all_users)
    end
  end
end
