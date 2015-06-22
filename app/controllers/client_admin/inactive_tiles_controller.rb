class ClientAdmin::InactiveTilesController < ClientAdminBaseController
  PER_PAGE = 12.freeze
  def index
    @demo = current_user.demo
    @raw_tiles = current_user.demo.archive_tiles.page(params[:page]).per(PER_PAGE)
    @archive_tiles = Demo.add_placeholders @raw_tiles
  end

  def sort
    @tile = get_tile
    Tile.insert_tile_between params[:left_tile_id], @tile.id, params[:right_tile_id]
    tile_status_updated_ping @tile
    render nothing: true
  end

  protected

  def get_tile
    current_user.demo.tiles.find params[:id]
  end

  def tile_status_updated_ping tile
    ping('Moved Tile in Manage', {action: "Dragged tile to move", tile_id: tile.id}, current_user)
  end
end
