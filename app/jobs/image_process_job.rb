require 'aws-sdk'

# Since image file Uploads are asynchronous for new and updated tiles
# We need to manually set the image attachment that would normally have been
# submitted via the file field on the form.
# In the case of an uploaded image to s3 we use the url to get the image and
# create the attachment
# When the image is from the library we use the existing attachment(s) and simply
# copy them to the new tile
#

class ImageProcessJob

  def initialize(tile_id, lib_img_id=nil)
    @tile = Tile.find(tile_id)
    @library_image_id = lib_img_id
  end

  def perform
    if library_image
      @tile.thumbnail = library_image.thumbnail
      @tile.image = library_image.image
    else
      @tile.image = @tile.thumbnail = image_path
    end

    @tile.save
  rescue TypeError
    Rails.logger.info("!!!! --- TypeError from media url  caught")
    nil
  end


  def image_path
    #TODO fix me in test
    URI.parse(URI.encode(@tile.remote_media_url))

  end

  def library_image
    @lib_image ||=TileImage.where(id: @library_image_id).first
  end

  handle_asynchronously :perform
end
