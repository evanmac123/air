class Admin::RecommendedTilesController < AdminBaseController

  include ExploreHelper

  def index
    @tiles = Tile.copyable.limit(10)
  end

  def create

  end

  def delete

  end

end
