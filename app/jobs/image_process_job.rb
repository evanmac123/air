# Since image file Uploads are asynchronous for new and updated tiles
# We need to manually set the image attachment that would normally have been
# submitted via the file field on the form.
# In the case of an uploaded image to s3 we use the url to get the image and
# create the attachment.

class ImageProcessJob < ActiveJob::Base
  def perform(id:)
    tile = Tile.find(id)
    image_path = URI.parse(URI.encode(tile.remote_media_url.to_s))

    tile.image = tile.thumbnail = image_path
    tile.save
  rescue TypeError
    Rails.logger.info("!!!! --- TypeError from media url  caught")
    nil
  end
end
