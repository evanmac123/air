class ClientAdmin::TileCompletionsController < ClientAdminBaseController
  #Tiles completion report
  def index    
    @tile = Tile.find(params[:tile_id])
    params[:grid] = {page: params[:page]}
    if params[:nc_grid]
      return non_completions
    else
      if params[:tc_grid] && params[:tc_grid][:order] == 'users.name'
        #params[:tc_grid][:order] = nil#tile_completions.sort_by(&:users.name)
        
        tile_completions = TileCompletion.joins("LEFT JOIN #{User.table_name} on user_id = #{User.
        table_name}.id AND user_type = '#{User.name}'").
        joins("LEFT JOIN #{GuestUser.table_name} on user_id = #{GuestUser.
        table_name}.id AND user_type = '#{GuestUser.name}' AND #{TileCompletion.table_name}.tile_id = #{@tile.id}").
          order("CASE WHEN #{User.
          table_name}.id IS NULL THEN 'Guest User[' || #{GuestUser.
          table_name}.id ||']' ELSE #{User.table_name}.name end #{params[:tc_grid][:order_direction]}")
      else
        tile_completions = TileCompletion.where(tile_id: @tile.id)
      end
      @tile_completions_grid = initialize_grid(tile_completions, name: 'tc_grid')
    end
  end
  
  def non_completions
    @tile = Tile.find(params[:tile_id])
    @non_completions_grid = initialize_grid(@tile.demo.users.joins("LEFT JOIN #{TileCompletion.
        table_name} on #{TileCompletion.table_name}.user_id = #{User.
        table_name}.id AND #{TileCompletion.table_name}.user_type = '#{User.
        name}' AND #{TileCompletion.table_name}.tile_id = #{@tile.id}").
        where("#{TileCompletion.table_name}.id is null"), name: 'nc_grid')
    render :non_completions
  end
end
