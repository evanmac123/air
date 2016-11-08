class Admin::RecommendedTilesController < AdminBaseController

  include ExploreHelper

  def index
    @tiles = Tile.verified_explore
  end

  def create
    t = RecommendedTile.new
    t.tile_id = params[:tile_id]
    t.save
    render json: {id: t.id, path: admin_recommended_tile_path(t)}, status: :ok
  end


  def destroy
    t = RecommendedTile.find(params[:id])
    if t
      t.delete
      render json: {id: t.tile_id, path: admin_recommended_tiles_path}, status: :ok
    end
  end
end
