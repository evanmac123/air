class ClientAdmin::TileCompletionsController < ClientAdminBaseController
  #Tiles completion report
  def index    
    @tile = Tile.find(params[:tile_id])
    params[:grid] = {page: params[:page]}
    @tile_completions = TileCompletion.where(tile_id: @tile.id).page(params[:page]).per(1)
    @tile_completions_grid = initialize_grid(TileCompletion.where(tile_id: @tile.id))
  end
  
  def non_completions
    @tile = Tile.find(params[:tile_id])
    @non_completions_grid = initialize_grid(@tile.demo.users.
        joins("LEFT JOIN #{TileCompletion.table_name} on user_id = #{User.
        table_name}.id").where("#{TileCompletion.table_name}.id is null"))
  end
end
