class ClientAdmin::ImagesController < ClientAdminBaseController
  IMAGE_POLL_DELAY = 5

  before_filter :find_tile

  def show
    render inline: [
      {
        'stillProcessing' => @tile.image_really_still_processing, 
        'imageURL' => @tile.image.url, 
        'type' => 'image',
        'imageHeight' => @tile.full_size_image_height
      }
    ].to_json
  end

  def update
    new_image = params[:tile_builder_form].try(:[], :image)
    @tile.image = @tile.thumbnail = new_image

    if @tile.save(:context => :client_admin)
      flash[:success] = "OK, you've uploaded a new image."
    else
      flash[:failure] = "Please select an image if you'd like to upload a new one."
    end

    redirect_to :back
  end

  def find_tile
    @tile = current_user.demo.tiles.find params[:tile_id]
  end
end
