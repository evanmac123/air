class TilesController < ApplicationController

  before_filter :get_displayable, :only => :index

  def index
    @start_tile = session[:start_tile] || @first_id
    session.delete(:start_tile)
  end

  def create
    session[:start_tile] = params[:start]
    redirect_to tiles_path
  end

  protected

  def get_displayable
    @displayable_tiles = Tile.displayable_to_user(current_user) 
    TileCompletion.mark_displayed_one_final_time(current_user)
    @satisfiable_tiles = Tile.satisfiable_to_user(current_user)
    @first_id = @satisfiable_tiles.first.try(:id)
  end

end
