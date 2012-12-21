class TilesController < ApplicationController

  before_filter :get_displayable, :only => :index

  def index
    invoke_tutorial
    @start_tile = session[:start_tile] || @first_id
    session.delete(:start_tile)
  end

  def show
    session[:start_tile] = params[:id]
    redirect_to tiles_path
  end

  protected

  def get_displayable
    TileCompletion.mark_displayed_one_final_time(current_user)
    @satisfiable_tiles = Tile.satisfiable_to_user_with_sample(current_user)
    @first_id = @satisfiable_tiles.first.try(:id)
  end

end
