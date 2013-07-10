class ClientAdmin::TilesReportsController < ClientAdminBaseController

  ReportRow = Struct.new :thumbnail, :headline, :num_completed, :percent_claimed, :percent_all

  def index
    demo = current_user.demo

    num_all_users     = demo.users.count
    num_claimed_users = demo.claimed_user_count

    active_tiles  = demo.active_tiles
    archive_tiles = demo.archive_tiles

    #num_completed_active = ative_tiles.group(:tile_id).count

    @active_tiles  = []
    @archive_tiles = []

    active_tiles .each do |tile|
      num_completed = TileCompletion.where(tile_id: tile.id).count.to_f
      @active_tiles << ReportRow.new(tile.thumbnail,
                                     tile.headline,
                                     num_completed,
                                     (num_completed / num_claimed_users) * 100,
                                     (num_completed / num_all_users) * 100)
    end

    archive_tiles .each do |tile|
      num_completed = TileCompletion.where(tile_id: tile.id).count.to_f
      @archive_tiles << ReportRow.new(tile.thumbnail,
                                      tile.headline,
                                      num_completed,
                                      (num_completed / num_claimed_users) * 100,
                                      (num_completed / num_all_users) * 100)
    end
  end
end
