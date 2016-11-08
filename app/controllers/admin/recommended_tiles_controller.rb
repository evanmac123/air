class Admin::RecommendedTilesController < AdminBaseController

  include ExploreHelper

  def index
    @tiles = Tile.copyable
  end

  def create
    t = RecommendedTile.new
    t.tile_id = params[:tile_id]
    t.save
    render json: {id: t.id, path: admin_recommended_tile_path(t)}, status: :ok
  end


  def destroy
    #NOTE the use where instead of find to avoid 404 if record is not found
    t = RecommendedTile.where({id:params[:id]}).first
    if t
      t.delete
      render json: {id: t.tile_id, path: admin_recommended_tiles_path}, status: :ok
    else
      response.headers["X-Message"]="Recommended Tile not found"
      head :unprocessible_entity
    end
  end

end
