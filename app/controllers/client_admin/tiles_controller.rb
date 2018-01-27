# frozen_string_literal: true

require "custom_responder"
class ClientAdmin::TilesController < ClientAdminBaseController
  include ClientAdmin::TilesHelper
  include ClientAdmin::TilesPingsHelper
  include CustomResponder

  before_action :get_demo, except: [:index]
  before_action :permit_params, only: [:create, :update]

  def index
    @tiles_facade = ClientAdminTilesFacade.new(demo: current_user.demo)
  end

  def show
    @tile = get_tile
    prepTilePreview
    if request.xhr?
      render layout: false
    end
  end

  def blank
    render "blank", layout: "empty_layout"
  end

  def new
    @tile = @demo.tiles.build(status: Tile::DRAFT)
    new_or_edit @tile
  end

  def edit
    @tile = get_tile
    new_or_edit @tile
  end

  # TODO: I don't think the first conditional branch ever gets hit.  See not about update_status endpoint.

  def update
    @tile = get_tile

    @tile.assign_attributes(params[:tile])
    update_or_create @tile do
      render_preview_and_single
    end
  end

  def create
    @tile = @demo.tiles.build(params[:tile].merge(creator_id: current_user.id))

    update_or_create @tile do
      schedule_tile_creation_ping(@tile, "Self Created")
      render_preview_and_single
    end
  end

  def destroy
    @tile = get_tile
    if @tile
      @tile.destroy
      # FIXME why is the ping destroy tile ping necessary?
      destroy_tile_ping params[:page]
    end

    if request.xhr?
      head :ok
    else
      redirect_to client_admin_tiles_path
    end
  end

  # FIXME Move status change to Api::Tile::StatusChangesController as a temp fix before moving to simple Tile api that manages templateing on teh fron end. This will clean up multiple separation of concerns issues with status changes and sorting as well as clena up this controller.

  def status_change
    @tile = get_tile
    Tile::Sorter.call(tile: @tile, params: params[:sort])

    presenter = present(@tile, SingleAdminTilePresenter, is_ie: browser.ie?, from_search: params[:from_search])
    render partial: partial_to_render, locals: { presenter: presenter }
  end

  def update_explore_settings
    tpf = TilePublicForm.new(get_tile, params[:tile_public_form])
    tpf.save
    @tile = tpf.tile
    render_preview_and_single
  end

  def duplicate
    @tile = get_tile.copy_inside_demo(current_user.demo, current_user)
    render_preview_and_single
  end

  private

    def partial_to_render
      "client_admin/tiles/manage_tiles/single_tile"
    end

    def permit_params
      params.require(:tile).permit!
    end

    def prepTilePreview
      unless from_search?
        @next_tile = @tile.next_tile_in_board
        @prev_tile = @tile.prev_tile_in_board
      end
    end

    def get_demo
      @demo = current_user.demo
    end

    def get_tile
      current_user.demo.tiles.find_by(id: params[:id])
    end

    def flash_status_messages
      success, failure = case params[:update_status]
                         when Tile::ARCHIVE
                           ["archived", "archiving"]
                         when Tile::ACTIVE
                           ["published", "publishing"]
                         when Tile::USER_SUBMITTED
                           ["moved to submitted", "with moving to submitted"]
                         when Tile::IGNORED
                           ["ignored", "ignoring"]
                         when Tile::DRAFT
                           ["accepted", "accepting"]
                         else
                           ["", ""]
      end
      [success, failure]
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

    def render_single_tile
      render partial: "client_admin/tiles/manage_tiles/single_tile", locals: { presenter: tile_presenter }
    end

    def tile_presenter(tile = @tile)
      @presenter ||= present(tile, SingleAdminTilePresenter, is_ie: browser.ie?)
    end

    def render_tile_preview_string
      render_to_string(action: "show", layout: false)
    end

    def set_after_save_flash(new_tile)
      flash[:success] = "Tile #{params[:action] || 'create' }d! We're resizing the graphics, which usually takes less than a minute."
    end

    def set_flash_for_no_image
      if @tile.no_image
        flash.now[:failure] = render_to_string("client_admin/tiles/form/save_tile_without_an_image", layout: false, locals: { tile: @tile.tile })
        flash[:failure_allow_raw] = true
      end
    end

    def builder_options
      {
        form_params: params[:tile],
        creator: current_user,
        action: params[:action]
      }
    end

    def render_preview_and_single
      prepTilePreview
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
      request.referrer && request.referrer.include?("explore/search")
    end
end
