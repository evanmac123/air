require 'aws-sdk'

class ImageProcessJob

  def initialize(tile_id)
    @tile = Tile.find(tile_id)
  end


  #TODO set obj in initializer
  def perform
    @tile.thumbnail = URI.parse(@tile.remote_media_url)
    @tile.save
  end
  handle_asynchronously :perform
end
