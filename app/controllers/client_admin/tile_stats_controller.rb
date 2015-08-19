class ClientAdmin::TileStatsController < ClientAdminBaseController
  before_filter :find_tile_and_demo

  def index
    @tile_completions = TileCompletion.tile_completions_with_users(@tile.id)
    @chart = TileStatsChart.new(@tile).draw
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
