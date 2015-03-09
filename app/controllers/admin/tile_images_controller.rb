class Admin::TileImagesController < AdminBaseController
  def index
    @tile_images = TileImage.order{ created_at.desc }
    @new_tile_image = TileImage.new
  end

  def create
    tile_image = TileImage.new(image: params_image, thumbnail: params_image)
    if tile_image.save
      flash[:success] = "Image was saved"
    else
      flash[:failure] = "Sorry, couldn't save this image: " + tile_image.errors.values.join(", ")
    end
    redirect_to :back
  end

  def destroy
    TileImage.find(params[:id]).destroy
    flash[:success] = "Image was destroyed"
    redirect_to :back
  end

  protected

  def params_image
    params[:tile_image][:image] if params[:tile_image]
  end
end