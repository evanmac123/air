class TileImageProcessor
  def self.call(tile:)
    TileImageProcessor.new(tile).process_image
  end

  attr_reader :tile

  def initialize(tile)
    @tile = tile
  end

  def process_image
    tile.image = tile.thumbnail = image_path
    tile.save
  rescue TypeError
    Rails.logger.info("!!!! --- TypeError from media url  caught")
  end

  private

    def image_path
      URI.parse(URI.encode(tile.remote_media_url.to_s))
    end
end
