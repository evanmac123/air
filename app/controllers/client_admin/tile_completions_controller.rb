class ClientAdmin::TileCompletionsController < ClientAdminBaseController
  #Tiles completion report
  ORDER_BY_USER_NAME  = 'users.name'.freeze
  def index    
    @tile = Tile.find(params[:tile_id])
    @survey_chart = @tile.survey_chart if @tile.is_survey?
    params[:grid] = {page: params[:page]}
    if params[:nc_grid]
      return non_completions
    else
      if params[:tc_grid] && params[:tc_grid][:order] == ORDER_BY_USER_NAME
        #params[:tc_grid][:order] = nil#eat up order param as we're doing it custom
        
        tile_completions = TileCompletion.joins("LEFT JOIN #{User.table_name} on #{TileCompletion.table_name}.user_id = #{User.
        table_name}.id AND user_type = '#{User.name}'").
        joins("LEFT JOIN #{GuestUser.table_name} on user_id = #{GuestUser.
        table_name}.id AND user_type = '#{GuestUser.name}'").
        where("#{TileCompletion.table_name}.tile_id = ?", @tile.id)
      
        @tile_completions_grid = initialize_grid(tile_completions, {name: 'tc_grid',
          custom_order: {ORDER_BY_USER_NAME => "CASE WHEN #{User.
            table_name}.id IS NULL THEN 'Guest User[' || #{GuestUser.
            table_name}.id ||']' ELSE #{User.table_name}.name end"
          }}
        )
      else
        tile_completions = TileCompletion.where(tile_id: @tile.id)
        @tile_completions_grid = initialize_grid(tile_completions, 
          name: 'tc_grid', order: 'created_at', order_direction: 'desc')
      end
    end
  end
  
  def non_completions
    @tile = Tile.find(params[:tile_id])
    @non_completions_grid = initialize_grid(@tile.demo.users.joins("LEFT JOIN #{TileCompletion.
        table_name} on #{TileCompletion.table_name}.user_id = #{User.
        table_name}.id AND #{TileCompletion.table_name}.user_type = '#{User.
        name}' AND #{TileCompletion.table_name}.tile_id = #{@tile.id}").
        where("#{TileCompletion.table_name}.id is null"), 
      name: 'nc_grid', order: 'name', order_direction: 'asc')
    render :non_completions
  end
end
