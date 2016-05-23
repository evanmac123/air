class ClientAdmin::StockTilesController < ClientAdminBaseController

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
    render_to_string("viewer", layout: false)
  end


end
