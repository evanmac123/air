require 'aws-sdk'

class ImageProcessJob

  def initialize(tile_id)
    @tile_id = tile_id
  end

  def perform
    tile = Tile.find(@tile_id)
    tile.image = tile.thumbnail = URI.parse(tile.remote_media_url)
    tile.save
  end

  handle_asynchronously :perform
end
