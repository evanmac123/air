class ClientAdmin::DraftTilesController < ClientAdminBaseController
  PER_PAGE = 12.freeze

  def index
    @demo = current_user.demo
    @raw_tiles = get_page(params[:page])
    @draft_tiles = add_creation_and_other_placeholders(params[:page], @raw_tiles)
  end

  def get_page page
    if page.nil? || page == 1 || page == ""
      current_user.demo.draft_tiles.page(1).per(PER_PAGE).limit(11)
    else
      current_user.demo.draft_tiles.page(page).per(PER_PAGE).padding(-1)
    end
  end

  def add_creation_and_other_placeholders page, tiles
    if page.nil? || page == 1 || page == ""
      current_user.demo.add_placeholders([TileCreationPlaceholder.new] + tiles)
    else
      current_user.demo.add_placeholders(tiles)
    end
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
