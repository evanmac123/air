class TilesController < ApplicationController
  include AllowGuestUsersConcern
  include AuthorizePublicBoardsConcern
  include TileBatchHelper
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  include ActsHelper

     #FIXME FIXME this logic is sooooooo convoluted!!!!!
  # so I don't forget the next time i look at this crazy code
  # Index and show essentially do the same thing display a single tiles_path
  # index renders it in the slideshow
  # the first time around the else path is triggered and we render the index
  # template
  # the second time we render the partial via ajax.

  def index
    @demo ||= current_user.demo
    @palette = @demo.custom_color_palette
    @current_user = current_user
    if params[:partial_only]
      render_tile_wall_as_partial
    elsif params[:from_search] == "true"
      @start_tile = Tile.find_by_id(params[:tile_id])
      @current_tile_ids = params[:tile_ids].split(", ")
    else
      @in_public_board = params[:public_slug].present?

      @start_tile = find_start_tile

      @current_tile_ids = satisfiable_tiles.map(&:id)
      decide_if_tiles_can_be_done(satisfiable_tiles)

      schedule_viewed_tile_ping(@start_tile)
      increment_tile_views_counter @start_tile, current_user
      session.delete(:start_tile)
      @hide_cover = true
      if params[:user_onboarding]
        @user_onboarding = UserOnboarding.find(params[:user_onboarding])
        render layout: "onboarding"
      end
    end
  end

  def show
    if params[:partial_only]
      new_tile_was_rendered = render_new_tile
      if new_tile_was_rendered
        schedule_viewed_tile_ping(current_tile)
        increment_tile_views_counter current_tile, current_user
      end
      mark_all_completed_tiles
    else
      session[:start_tile] = params[:id]
      if params[:public_slug]
        redirect_to public_tiles_path(params[:public_slug])
      elsif params[:user_onboarding_id]
        redirect_to tiles_path({ user_onboarding: params[:user_onboarding_id] })
      else
        redirect_to tiles_path({ tile_ids: params[:tile_ids], from_search: params[:from_search], tile_id: params[:id]})
      end
    end
  end

  private

    def find_start_tile
      if start_tile_id.to_s == '0'
        current_user.sample_tile
      elsif start_tile_id.present?
        candidate = Tile.find(start_tile_id)
        if (candidate.is_sharable) || (candidate.demo_id == current_user.demo_id)
          candidate
        else
          nil
        end
      else
        nil
      end
    end

    def start_tile_id
      session[:start_tile] || first_id
    end

    def first_id
      satisfiable_tiles.first.try(:id)
    end

    def render_new_tile
      after_posting = params[:afterPosting] == "true"
      all_tiles_done = user_satisfiable_tiles.empty?
      all_tiles = current_user.available_tiles_on_current_demo.count
      completed_tiles = current_user.completed_tiles_on_current_demo.count
      render json: {
        ending_points: current_user.points,
        ending_tickets: current_user.tickets,
        flash_content: render_to_string('shared/_flashes', layout: false),
        tile_content: tile_content(all_tiles_done, after_posting),
        all_tiles_done: all_tiles_done,
        show_start_over_button: current_user.can_start_over?,
        raffle_progress_bar: raffle_progress_bar * 10,
        all_tiles: all_tiles,
        completed_tiles: completed_tiles
      }
      !(all_tiles_done && after_posting)
    end

    def tile_content(all_tiles_done, after_posting)
      if all_tiles_done && after_posting
        render_to_string("tiles/_all_tiles_done", layout: false)
      else
        @start_tile  = current_tile
        render_to_string("tiles/_viewer",  layout: false)
      end
    end

    def current_tile_index
      @idx ||= if satisfiable_tiles.empty?
              0
      elsif not previous_tile_ids.empty?
        (previous_tile_index + params[:offset].to_i) % (current_tile_ids.length > 0 ? current_tile_ids.length : 1)
      else
        (current_tile_ids.find_index{|element| element.to_i == reference_tile_id.to_i}) || 0
      end
    end

    def current_tile_id
      current_tile_ids[current_tile_index]
    end

    def current_tile
      @tile ||= Tile.find(current_tile_id)
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

    def previous_tile_index
      (previous_tile_ids.find_index{|element| element.to_i == reference_tile_id.to_i})||0
    end


    def render_tile_wall_as_partial
      html_content = render_to_string partial: "shared/tile_wall", locals: (Tile.displayable_categorized_to_user(current_user, maximum_tiles_wanted)).merge(path_for_more_tiles: tiles_path(board_id: params[:board_id]))
      render json: {htmlContent: html_content}
    end

    def show_completed_tiles
      @show_completed_tiles ||=  (params[:completed_only] == 'true') ||
        (session[:start_tile] &&
          current_user.tile_completions.where(tile_id: session[:start_tile]).exists?) || false
    end

    def user_satisfiable_tiles
      @user_tiles ||= Tile.satisfiable_to_user(current_user, params[:demo])
    end

    def satisfiable_tiles
      @_satisfiable_tiles ||= begin
        unless show_completed_tiles
          user_satisfiable_tiles
        else
          current_user.tile_completions.order("#{TileCompletion.table_name}.id desc").includes(:tile).where("#{Tile.table_name}.demo_id" => current_user.demo_id).map(&:tile)
        end
      end
    end

    def schedule_viewed_tile_ping(tile)
      return unless tile.present?
      board_type = tile.demo.is_paid ? "Paid" : "Free"
      tile_type = tile.is_invite_spouse? ? "Spouse Invite" : "User"
      ping('Tile - Viewed', {tile_type: tile_type, tile_id: tile.id, board_type: board_type}, current_user)
    end

    def maximum_tiles_wanted
      offset = params[:offset].to_i
      offset + tile_batch_size - (offset % tile_batch_size)
    end

    def mark_all_completed_tiles
      if Tile.satisfiable_to_user(current_user).empty?
        current_user.not_show_all_completed_tiles_in_progress
      end
    end

    def increment_tile_views_counter tile, user
      tile.viewed_by(user) if tile
    end
end
