class TilesController < ApplicationController
  include TileBatchHelper

  prepend_before_filter :allow_guest_user, :only => [:index, :show]
  before_filter :get_displayable, :only => :index
  before_filter :get_position_description, :only => :index

  def index
    @current_user = current_user
    
    @start_tile = if start_tile_id.to_s == '0'
                    current_user.sample_tile
                  elsif start_tile_id.present?
                    Tile.find(start_tile_id)
                  else
                    nil
                  end                      
    
    @current_tile_ids = satisfiable_tiles.map(&:id)
    decide_if_tiles_can_be_done(satisfiable_tiles)

    session.delete(:start_tile)

    decide_whether_to_show_conversion_form

    if params[:partial_only]
      render_tile_wall
    else
      schedule_viewed_tile_ping(@start_tile)
    end
  end

  def show
    if params[:partial_only]
      get_displayable
      get_position_description
      render_new_tile
      schedule_viewed_tile_ping(current_tile)
    else
      session[:start_tile] = params[:id]
      if params[:public_slug]
        redirect_to public_tiles_path(params[:public_slug])
      else
        redirect_to tiles_path
      end
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
    #add new tiles to the end of the previous tiles
    render "tiles/_full_size_tile", locals: {tile: current_tile, current_tile_ids: current_tile_ids}, layout: false
  end
  
  def current_tile_ids
    @current_tile_ids ||= begin
      not_completed_tile_ids = satisfiable_tiles.map(&:id)
      new_tile_ids = not_completed_tile_ids - previous_tile_ids
      current_tile_ids = previous_tile_ids + new_tile_ids      
      current_tile_ids
    end
  end
  
  def previous_tile_ids
    @_previous_tile_ids ||= (params[:previous_tile_ids] && params[:previous_tile_ids].split(',').collect{|el| el.to_i}) || []
  end

  def reference_tile_id
    params[:id] || start_tile_id
  end
  
  def current_tile_id    
    current_tile_ids[current_tile_index]
  end
  
  def current_tile
    @_current_tile ||= Tile.find(current_tile_id)
  end

  def previous_tile_index
    (previous_tile_ids.find_index{|element| element.to_i == reference_tile_id.to_i})||0
  end

  def current_tile_index
    return 0 if satisfiable_tiles.empty?
    return (previous_tile_index + params[:offset].to_i) % 
    (current_tile_ids.length > 0 ? current_tile_ids.length : 1) unless previous_tile_ids.empty?
    return (current_tile_ids.find_index{|element| element.to_i == reference_tile_id.to_i}) || 0
  end
  
  def get_position_description
    #TODO change this to use params[:tile_ids] and incorporate any new tile added 
    @current_tile_position_description = "Tile #{current_tile_index+1} of #{current_tile_ids.length}"
  end

  def render_tile_wall
    render partial: "shared/tile_wall", 
      locals: Tile.displayable_categorized_to_user(current_user, tile_batch_size)      
  end

  def decide_whether_to_show_conversion_form
    #return (@show_conversion_form = true)

    active_tile_count = @current_user.demo.tiles.active.count

    if active_tile_count == 1
      show_conversion_form_provided_that { satisfiable_tiles.empty? }
    else
      allow_reshow = @current_user.tile_completions.count == active_tile_count

      show_conversion_form_provided_that(allow_reshow) { @current_user.tile_completions.count == 2 || @current_user.tile_completions.count == active_tile_count }
    end
  end

  def show_completed_tiles    
    @show_completed_tiles ||=  (params[:completed_only] == 'true') || 
      (session[:start_tile] && 
        current_user.tile_completions.where(tile_id: session[:start_tile]).exists?) || false
  end
  
  def satisfiable_tiles
    @_satisfiable_tiles ||= begin
      unless show_completed_tiles
        Tile.satisfiable_to_user(current_user)
      else
        current_user.completed_tiles.order('id desc')
      end
    end
  end

  def find_current_board
    current_user.demo
  end

  def schedule_viewed_tile_ping(tile)
    return unless tile.present?
    ping('Tile - Viewed', {tile_id: tile.id}, current_user)
  end
end
