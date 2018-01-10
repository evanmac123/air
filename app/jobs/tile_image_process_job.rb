# Since image file Uploads are asynchronous for new and updated tiles We need to manually set the image attachment that would normally have been submitted via the file field on the form. In the case of an uploaded image to s3 we use the url to get the image and create the attachment.

class TileImageProcessJob < ActiveJob::Base
  queue_as :high_priority

  def perform(id:)
    tile = Tile.find_by(id: id)
    TileImageProcessor.call(tile: tile) if tile
  end
end
