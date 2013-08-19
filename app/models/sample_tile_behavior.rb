module SampleTileBehavior
  ENV_SUBDIR = Rails.env.production? ? '' : '-staging'
  URL_BASE = "https://hengage-assets#{ENV_SUBDIR}.s3.amazonaws.com/assets/tutorial/"

  Attachment = Struct.new(:url, :image_size)

  def url_base
    URL_BASE
  end

  def image
    size_in_pixels = "620x620"
    Attachment.new(image_url, size_in_pixels)
  end

  # When we call .thumbnail, we just need the url (the size is hard-coded)
  def thumbnail(format = nil)
    case format 
    when :hover
      thumbnail_hover_url
    else
      thumbnail_url
    end
  end

  def image_url
    url_base + image_filename
  end

  def thumbnail_url
    url_base + thumbnail_filename
  end

  def thumbnail_hover_url
    url_base + thumbnail_hover_filename
  end

  def headline
    "Learn to Play"
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
