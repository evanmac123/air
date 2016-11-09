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
    #NOTE the use where instead of find to avoid 404 if record is not found
    recommended = RecommendedTile.where({id:params[:id]}).first
    if recommended

      recommended.delete
      render json: {id: recommended.tile_id, path: admin_recommended_tiles_path}, status: :ok

    else
      response.headers["X-Message"]="Recommended Tile not found"
      head :unprocessible_entity
    end
  end
end
