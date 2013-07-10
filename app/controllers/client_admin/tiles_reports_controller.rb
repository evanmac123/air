class ClientAdmin::TilesReportsController < ClientAdminBaseController

  ReportRow = Struct.new :thumbnail, :headline, :num_completed, :percent_claimed, :percent_all

  def index
    demo = current_user.demo

    num_all_users     = demo.users.count
    num_claimed_users = demo.claimed_user_count

p "CONTROLLER: all = #{num_all_users} and claimed = #{num_claimed_users}"
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
                                     completed_percent / num_all_users)
    end

    demo.archive_tiles.each do |tile|
      completed_percent = num_tile_completions[tile.id] * 100.0
      @archive_tiles << ReportRow.new(tile.thumbnail,
                                      tile.headline,
                                      num_tile_completions[tile.id],
                                      completed_percent / num_claimed_users,
                                      completed_percent / num_all_users)
    end
  end
end
