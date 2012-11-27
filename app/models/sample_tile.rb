class SampleTile < Tile

  ENV_SUBDIR = Rails.env.production? ? '' : '-staging'
  URL_BASE = "https://hengage-assets#{ENV_SUBDIR}.s3.amazonaws.com/assets/tutorial/"
  IMAGE_URL           = URL_BASE + "sample_tile_image.png"
  THUMBNAIL_URL       = URL_BASE + "sample_tile_thumbnail.png"
  THUMBNAIL_HOVER_URL = URL_BASE + "sample_tile_hover_thumbnail.png"

  Attachment = Struct.new(:url, :image_size)

  def image
    size_in_pixels = "620x620"
    Attachment.new(IMAGE_URL, size_in_pixels)
  end

  # When we call .thumbnail, we just need the url (the size is hard-coded)
  def thumbnail(format = nil)
    case format 
    when :hover
      THUMBNAIL_HOVER_URL 
    else
      THUMBNAIL_URL 
    end
  end


  def headline
    "Sample Tile"
  end

  def save
    # this way it's impossible to save one of these puppies
  end

  def position
    0 
  end

  def id
    0
  end
end

