class SuggestedTilesController < ApplicationController
  def new
    @tile_builder_form =  current_user.demo.m_tiles.build(status: Tile::USER_SUBMITTED, user_created: true)
    @user_side = true
    render partial: "client_admin/tiles/form", layout: false and return
  end

  def show
    get_tile
    render layout: false
  end

  def create
    @tile_builder_form =  UserTileBuilderForm.new(
                            current_user.demo,
                            form_params:params.require(:tile_builder_form).permit!,
                            creator: current_user,
                            action: params[:action]
                          )

    if @tile_builder_form.create_tile
      @tile = @tile_builder_form.tile
      render_preview
    else
      response.headers["X-Message"]= @tile_builder_form.error_message
      head :unprocessable_entity and return
    end
  end

  private

  def get_tile_images
    @tile_images = TileImage.all_ready.first(TileImage::PAGINATION_PADDING)
  end

  def get_tile
    @tile = current_user.tiles.find(params[:id])
  end

  def render_preview
    @prev = @next = @tile
    render json: {
      preview: render_to_string(action: 'show', layout: false)
    }
  end
end
