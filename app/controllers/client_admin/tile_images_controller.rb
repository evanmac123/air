class ClientAdmin::TileImagesController < ClientAdminBaseController
  def index
    @curr_page = params[:page].to_i + 1
    @tile_images = TileImage.all_ready.page(@curr_page).padding(TileImage::PAGINATION_PADDING)
    @last_page = @tile_images.last_page?

    if @curr_page > 0 
      render partial: "/shared/tiles/form/tile_images", layout: false and return
    else
      render partial: "/shared/tiles/form/image_library", layout: false and return
    end
  end
end
