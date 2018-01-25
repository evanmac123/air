# frozen_string_literal: true

class SuggestedTilesController < UserBaseController
  def new
    @tile = current_board.tiles.build(status: Tile::USER_SUBMITTED, user_created: true)
    render partial: "client_admin/tiles/form", layout: false
  end

  def create
    @tile = current_user.demo.tiles.new(tile_params)

    if @tile.save
      render_preview
    else
      render json: { errors: @tile.errors }
    end
  end

  private

    def render_preview
      render json: {
        preview: render_to_string(action: "show", layout: false)
      }
    end

    def tile_params
      params.require(:tile).permit!.merge(
        creator: current_user,
        status: Tile::USER_SUBMITTED,
        creation_source: :suggestion_box_created
      )
    end
end
