class ClientAdmin::TileCompletionsController < ClientAdminBaseController
  before_filter :find_tile_and_demo
  def index
    @survey_chart = @tile.survey_chart if @tile.is_survey?
    params[:grid] = {page: params[:page]}
    if params[:nc_grid]
      return non_completions
    else
      @tile_completions_grid = initialize_grid(
        TileCompletion.tile_completions_with_users(@tile.id), 
        TileCompletion.tile_completion_grid_params
      )
      export_grid_if_requested('tc_grid' => 'tile_completions')
    end
    TrackEvent.ping_page('Tile More Info Page', {}, current_user) 
  end

  def non_completions
    @non_completions_grid = initialize_grid(
      TileCompletion.non_completions_with_users(@tile), 
      TileCompletion.non_completion_grid_params
    )
    render :non_completions
  end

  protected

  def find_tile_and_demo
    @tile = Tile.find(params[:tile_id])
    @demo = @tile.demo
  end
end
