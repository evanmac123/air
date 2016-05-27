class ClientAdmin::StockTilesController < ClientAdminBaseController
  before_filter :clear_server_side_tile_completions
  def show
    @current_user = current_user
    @tile = Tile.find(params[:id])
    @demo = @tile.demo
    @prev, @next = @demo.bracket @tile
    @current_tile_ids = @demo.tiles.active.order("activated_at desc").map(&:id)
    if request.xhr?
      render_tile_partial_as_json
    end

  end

  private


  def render_tile_partial_as_json
    render json: {
      tile_content:  tile_content, 
      ending_points: 0,
      ending_tickets: 0,
      flash_content: "",
      all_tiles_done: false,
      show_conversion_form: false,
      show_start_over_button: false,
      raffle_progress_bar: 0,
      all_tiles: [],
      completed_tiles:[] 
    }
  end

  def tile_content
    render_to_string("_viewer", layout: false)
  end

  def clear_server_side_tile_completions
    #NOTE this is a small hack to prevent the shared tile display logic from 
    #showing library tiles as completed  if the tile happened to be completed by
    #the current_user in another context e.g public boards.
    #
    # In the library tile completion status is tracked on the client only and ignores server
    # side tile completion state
    current_user.tile_completions=[]
  end


end
