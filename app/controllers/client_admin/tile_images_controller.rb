class ClientAdmin::TileImagesController < ClientAdminBaseController
  def index
    set_images_page_context
    render partial: @partial_to_render, layout: false
  end


  private

  def ready_images
    TileImage.all_ready
  end

  def set_images_page_context
    if params[:page]
      @curr_page = params[:page].to_i + 1
      @tile_images = ready_images.page(@curr_page).padding(TileImage::PAGINATION_PADDING)
      @last_page = @tile_images.last_page?
      @partial_to_render ="/shared/tiles/form/tile_images"
    else
      @curr_page=0
      @tile_images = ready_images.limit(TileImage::PAGINATION_PADDING)
      @partial_to_render = "/shared/tiles/form/image_library"
    end

  end

end
