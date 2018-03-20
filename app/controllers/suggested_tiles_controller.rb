# frozen_string_literal: true

class SuggestedTilesController < UserBaseController
  def new
    @tile = current_board.tiles.new(status: Tile::USER_SUBMITTED)

    render json: {
      tileForm: render_tile_form_string
    }
  end

  def create
    @tile = current_user.demo.tiles.new(tile_params)

    if @tile.save
      render json: {
        preview: render_preview_string
      }
    else
      render json: { errors: @tile.errors }
    end
  end

  private

    def render_tile_form_string
      render_to_string(partial: "client_admin/tiles/form", layout: false)
    end

    def render_preview_string
      render_to_string(action: "show", layout: false)
    end

    def tile_params
      params.require(:tile).permit!.merge(
        creator: current_user,
        status: Tile::USER_SUBMITTED,
        creation_source_cd: Tile.suggestion_box_created
      )
    end
end
