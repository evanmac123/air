module Concerns::TileImageable
  extend ActiveSupport::Concern
  include Assets::Normalizer # normalize filename of paperclip attachment

  IMAGE_PROCESSING_URL =  ActionController::Base.helpers.asset_path('resizing_gears_fullsize.gif')
  TILE_IMAGE_PROCESSING_PRIORITY = -10
  MISSING_THUMBNAIL = "missing-tile-img-thumb.png"
  MISSING_PREVIEW = "missing-search-image.png"

  included do

    has_attached_file :image,
      { styles: {
          viewer: "666>"
        },
        default_style: :viewer,
        default_url: MISSING_PREVIEW,
      }.merge!(TILE_IMAGE_OPTIONS)

    has_attached_file :thumbnail,
      {
        styles: {
          carousel:     "238x238#",
          email_digest: "190x160#"
        },
        default_style: :carousel,
        default_url: MISSING_THUMBNAIL,
        preserve_files: true
      }.merge!(TILE_THUMBNAIL_OPTIONS)

    process_in_background :image,
      processing_image_url: :processing_image_fallback,
      priority: TILE_IMAGE_PROCESSING_PRIORITY

    process_in_background :thumbnail,
      processing_image_url: :processing_image_fallback,
      priority: TILE_IMAGE_PROCESSING_PRIORITY
  end

  attr_accessor :image_from_library

  def processing_image_fallback
    remote_media_url || IMAGE_PROCESSING_URL
  end

  # need this function to set height of image place in ie8 while image is loading
  def full_size_image_height
    return nil if image_file_name.nil?

   #FIXME  this fails if height or width are nil?
    height, width = if image_processing? || image.height.nil? || image.width.nil?
                      [484, 666]
                    else
                      [image.height, image.width]
                    end

    full_width = 600.0 # px for full size tile
    ( height * full_width / width ).to_i
  end

  module ClassMethods
    include ValidImageMimeTypes
  end
end
