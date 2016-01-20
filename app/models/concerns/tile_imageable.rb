module Concerns::TileImageable
  extend ActiveSupport::Concern
  include Assets::Normalizer # normalize filename of paperclip attachment

  IMAGE_PROCESSING_URL =  ActionController::Base.helpers.asset_path('resizing_gears_fullsize.gif')
  TILE_IMAGE_PROCESSING_PRIORITY = -10

  included do

    has_attached_file :image,
      {
        # For those of you who don't read ImageMagick geometry arguments like a
        # native, "666>" means "Leave images under 666 pixels wide alone. Scale
        # down images over 666 pixels wide to 666 wide, maintaining the original
        # aspect ratio."
        styles:         {:viewer => ["666>", :png]},
        default_style:  :viewer,
        default_url:    "/assets/avatars/thumb/missing.png",
        bucket:         S3_TILE_BUCKET
      }.merge(TILE_IMAGE_OPTIONS)

    has_attached_file :thumbnail,
      {
        styles: {
          carousel:     ["238x238#", :png],
          email_digest: ["190x160#", :png]
        },
        default_style:  :carousel,
        default_url:    "/assets/avatars/thumb/missing.png",
        bucket:         S3_TILE_THUMBNAIL_BUCKET
      }.merge(TILE_THUMBNAIL_OPTIONS)

    process_in_background :image,
                          processing_image_url: :processing_image_fallback,
                          priority:             TILE_IMAGE_PROCESSING_PRIORITY

    process_in_background :thumbnail,
                          processing_image_url: :processing_image_fallback,
                          priority:             TILE_IMAGE_PROCESSING_PRIORITY


  end

  attr_accessor :image_from_library

  def processing_image_fallback
    remote_media_url || IMAGE_PROCESSING_URL
  end




  # need this function to set height of image place in ie8 while image is loading
  def full_size_image_height
    return nil if image_file_name.nil?

   #FIXME  this fails if height or width are nil?
    height, width = if image_processing?
                      [484, 666]
                    else
                      [image.height||484, image.width||666] #FIXME temporary hack
                    end

    full_width = 600.0 # px for full size tile
    ( height * full_width / width ).to_i
  end

  module ClassMethods
    include ValidImageMimeTypes
    #include Paperclip
  end
end
