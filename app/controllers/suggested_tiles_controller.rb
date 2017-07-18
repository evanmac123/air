class SuggestedTilesController < UserBaseController
  def new
 
    @image_providers = ENV['IMAGE_PROVIDERS'].split(",").to_json
    @tile =  current_user.demo.m_tiles.build(status: Tile::USER_SUBMITTED, user_created: true)
    @user_side = true
    render partial: "client_admin/tiles/form", layout: false and return
  end

  def show
    get_tile
    render layout: false
  end

  def create
    demo = current_user.demo


    @tile = demo.m_tiles.build(params.require(:tile).permit!)
    @tile.creator =current_user
    @tile.status =Tile::USER_SUBMITTED
    @tile.creation_source = :suggestion_box_created

    if @tile.save
      render_preview
    else
      response.headers["X-Message"]= @tile.error_message
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
