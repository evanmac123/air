class TilesController < ApplicationController

  def index
    @displayable_tiles = Tile.displayable_to_user(current_user) 
  end
end
