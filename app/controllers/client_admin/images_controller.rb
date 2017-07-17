class ClientAdmin::ImagesController < ClientAdminBaseController
  include ApplicationHelper
  IMAGE_POLL_DELAY = 5

  before_filter :find_tile

  def show
    #TODO is this still really needed? Since we no longer will poll for image processing
    render inline: [
      {
        'stillProcessing' => false, 
        'imageURL' => @tile.image.url, 
        'type' => 'image',
        'imageHeight' => (ie9_or_older? ? @tile.full_size_image_height : "")
      }
    ].to_json
  end

  def update
    new_image = params[:tile].try(:[], :image)
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
