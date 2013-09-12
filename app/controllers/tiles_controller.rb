class TilesController < ApplicationController

  before_filter :get_displayable, :only => :index
  before_filter :get_position_description, :only => :index

  def index
    @start_tile = if start_tile_id.to_s == '0'
                    current_user.sample_tile
                  else
                    Tile.find(start_tile_id)    
                  end

    @all_tiles_done = satisfiable_tiles.empty?
    session.delete(:start_tile)
  end

  def show
    if params[:partial_only]
      get_displayable
      get_position_description
      render_new_tile
    else
      session[:start_tile] = params[:id]
      redirect_to tiles_path
    end
  end

  protected

  def get_displayable
    TileCompletion.mark_displayed_one_final_time(current_user)
  end

  def start_tile_id
    session[:start_tile] || first_id
  end

  def first_id
    satisfiable_tiles.first.try(:id)
  end

  def render_new_tile
    next_tile = satisfiable_tiles[next_tile_index]

    render "tiles/_full_size_tile", locals: {tile: next_tile}, layout: false
  end

  def current_tile_id
    params[:id] || start_tile_id
  end

  def current_tile_index
    result = satisfiable_tiles.find_index{|tile| tile.id.to_s == current_tile_id.to_s}
    result || 0
  end

  def next_tile_index
    (current_tile_index + params[:offset].to_i) % (satisfiable_tiles.length)
  end

  def get_position_description
    @current_tile_position_description = "Tile #{next_tile_index + 1} of #{satisfiable_tiles.length}"
  end

  def satisfiable_tiles
    unless @_satisfiable_tiles
      @_satisfiable_tiles = Tile.satisfiable_to_user_with_sample(current_user)
    end

    @_satisfiable_tiles
  end
end
