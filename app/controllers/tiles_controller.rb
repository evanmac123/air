class TilesController < ApplicationController
  include TileBatchHelper
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  prepend_before_filter :allow_guest_user, :only => [:index, :show]
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
      render_tile_wall_as_partial
    else
      schedule_viewed_tile_ping(@start_tile)
    end
  end

  def show
    if params[:partial_only]
      decide_whether_to_show_conversion_form
      get_position_description
      render_new_tile
      schedule_viewed_tile_ping(current_tile)
      mark_all_completed_tiles
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

  def start_tile_id
    session[:start_tile] || first_id
  end

  def first_id
    satisfiable_tiles.first.try(:id)
  end

  def render_new_tile
    after_posting = params[:after_posting] == "true"
    all_tiles_done = Tile.satisfiable_to_user(current_user).empty?
    all_tiles = current_user.avaliable_tiles_on_current_demo.count
    completed_tiles = current_user.completed_tiles_on_current_demo.count
    render json: {
      delimited_starting_points: number_with_delimiter(starting_points),
      ending_points: current_user.points,
      ending_tickets: current_user.tickets,
      flash_content: render_to_string('shared/_flashes', layout: false),
      master_bar_point_content: master_bar_point_content,
      master_bar_ending_percentage: master_bar_ending_percentage,
      tile_content: tile_content(all_tiles_done, after_posting),
      all_tiles_done: all_tiles_done,
      show_conversion_form: @show_conversion_form,
      show_start_over_button: current_user.can_start_over?,
      raffle_progress_bar: raffle_progress_bar * 10,
      all_tiles: all_tiles,
      completed_tiles: completed_tiles
    }
  end
 
  def tile_content(all_tiles_done, after_posting)
    if all_tiles_done && after_posting
      render_to_string("tiles/_all_tiles_done", layout: false)
    else
      render_to_string("tiles/_full_size_tile", locals: {tile: current_tile, current_tile_ids: current_tile_ids, overlay_displayed: true}, layout: false)
    end
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
    @current_tile_position_description = "Tile #{current_tile_index+1} of #{current_tile_ids.length}"
  end

  def render_tile_wall_as_partial
    html_content = render_to_string partial: "shared/tile_wall", locals: (Tile.displayable_categorized_to_user(current_user, maximum_tiles_wanted)).merge(path_for_more_tiles: tiles_path)
    render json: {htmlContent: html_content}
  end

  def decide_whether_to_show_conversion_form
    #return (@show_conversion_form = true)
    @current_user ||= current_user
    active_tile_count = @current_user.demo.tiles.active.count

    if active_tile_count == 1
      show_conversion_form_provided_that { satisfiable_tiles.empty? }
    else
      tile_completion_count = @current_user.tile_completions.joins(:tile).where("#{Tile.table_name}.demo_id" => @current_user.demo_id).count
      allow_reshow = tile_completion_count == active_tile_count

      show_conversion_form_provided_that(allow_reshow) { tile_completion_count == 2 || tile_completion_count == active_tile_count }
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
        current_user.tile_completions.order("#{TileCompletion.table_name}.id desc").includes(:tile).where("#{Tile.table_name}.demo_id" => current_user.demo_id).map(&:tile)
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

  def maximum_tiles_wanted
    offset = params[:offset].to_i
    offset + tile_batch_size_increment - (offset % tile_batch_size_increment)
  end

  def mark_all_completed_tiles
    if Tile.satisfiable_to_user(current_user).empty?
      current_user.not_show_all_completed_tiles_in_progress
    end
  end
end
