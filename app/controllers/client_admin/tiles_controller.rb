# frozen_string_literal: true

# TODO: Move partial templates to front end.
class ClientAdmin::TilesController < ClientAdminBaseController
  include ClientAdmin::TilesHelper
  include ClientAdmin::TilesPingsHelper

  def index
    @tiles_facade = true
    @ctrl_data = {
      "audiencesEnabled" => current_user.demo.population_segments.first.present?
    }.to_json

    if !params[:partial_only]
      @react_spa = true
      render template: "react_spa/show"
    else
      render json: {}
    end
  end

  def show
    @tile = find_tile
    add_prev_next_tiles

    render json: {
      tilePreview: render_tile_preview_string
    }
  end

  def new
    @tile = current_board.tiles.build(status: Tile::PLAN)

    render json: {
      tileForm: render_tile_form_string
    }
  end

  def edit
    @tile = find_tile

    render json: {
      tileForm: render_tile_form_string
    }
  end

  def update
    @tile = find_tile

    if @tile.update_attributes(tile_params)
      render_preview_and_single
    else
      tile_error(@tile)
    end
  end

  def create
    @tile = current_board.tiles.build(tile_params.merge(creator_id: current_user.id))

    if @tile.save
      schedule_tile_creation_ping(@tile, "Self Created")
      render_preview_and_single
    else
      tile_error(@tile)
    end
  end

  def destroy
    @tile = find_tile
    if @tile
      @tile.destroy
    end

    render json: {
      meta: {
        tileCounts: current_board.tiles.group(:status).count
      }
    }
  end

  def duplicate
    @tile = TileDuplicateJob.perform_now(tile: find_tile, demo: current_user.demo, user: current_user)

    render_preview_and_single
  end

  private

    def tile_params
      # TODO: Find better way to manage nil options in radio button for Tile.campaign_id && Tile.ribbon_tag_id
      params[:tile][:campaign_id] = nil if params[:tile][:campaign_id].to_i == 0
      params[:tile][:ribbon_tag_id] = nil if params[:tile][:ribbon_tag_id].to_i == 0
      if params[:tile][:plan_date].present?
        params[:tile][:plan_date] = Date.parse(params[:tile][:plan_date])
      end

      params.require(:tile).permit!
    end

    def tile_error(tile)
      render json: { errors: tile.errors }, status: :unprocessable_entity
    end

    def add_prev_next_tiles
      @next_tile = @tile.next_tile_in_board
      @prev_tile = @tile.prev_tile_in_board
    end

    def find_tile
      current_user.demo.tiles.find_by(id: params[:id])
    end

    def render_tile_string
      if from_search?
        tile_presenter.options[:from_search] = true
      end

      render_to_string(
        partial: "client_admin/tiles/manage_tiles/single_tile",
        locals: { presenter:  tile_presenter }
      )
    end

    def tile_presenter(tile = @tile)
      @presenter ||= present(tile, SingleAdminTilePresenter, is_ie: browser.ie?)
    end

    def render_tile_preview_string
      render_to_string(action: "show", layout: false)
    end

    def render_tile_form_string
      render_to_string(partial: "form", layout: false)
    end

    def render_preview_and_single
      add_prev_next_tiles
      render json: {
        tileStatus: @tile.status,
        tileId: @tile.id,
        tile: render_tile_string,
        preview: render_tile_preview_string,
        updatePath: client_admin_tile_path(@tile),
        fromSearch: from_search?
      }
    end

    def from_search?
      request.referrer.to_s.include?("explore/search")
    end
end
