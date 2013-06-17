class ClientAdmin::ImagesController < ClientAdminBaseController
  def update
    tile = current_user.demo.tiles.find params[:tile_id]
    new_image = params[:tile_builder_form].try(:[], :image)
    tile.image = new_image

    if tile.save(:context => :client_admin)
      flash[:success] = "OK, you've uploaded a new image."
    else
      flash[:failure] = "Please select an image if you'd like to upload a new one."
    end

    redirect_to :back
  end
end
