class TilesController < ApplicationController

  before_filter :get_displayable

  def index
    @start_tile = session[:start_tile] || 0
    session.delete(:start_tile)
  end

  def create
    session[:start_tile] = params[:start]
    redirect_to tiles_path
  end

  protected

  def get_displayable
    @displayable_tiles = Tile.displayable_to_user(current_user) 
  end

end
