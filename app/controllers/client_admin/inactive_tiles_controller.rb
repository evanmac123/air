# frozen_string_literal: true

class ClientAdmin::InactiveTilesController < ClientAdminBaseController
  PER_PAGE = 16.freeze
  def index
    @demo = current_user.demo
    @raw_tiles = current_user.demo.archive_tiles.page(params[:page]).per(PER_PAGE)
    @archive_tiles = Tile::PlaceholderManager.call(@raw_tiles)
  end
end
