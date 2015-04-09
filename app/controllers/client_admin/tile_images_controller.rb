class ClientAdmin::TileImagesController < ClientAdminBaseController
  def index
    @tile_images = TileImage.all_ready.page(params[:page])
    render json: {
      tileImages: tile_image_containers,
      nextPageLink: next_page_link
    }
  end

  protected

  def tile_image_containers
    @tile_images.map do |tile_image|
      render_to_string("client_admin/tile_images/_tile_image", 
        locals: {tile_image: tile_image}, 
        layout: false
      )
    end.to_json
  end

  def next_page_link
    if @tile_images.last_page?
      nil
    else
      next_page = params[:page].to_i + 1
      client_admin_tile_images_path(page: next_page)
    end
  end
end