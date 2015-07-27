module Concerns::TileImageable
  extend ActiveSupport::Concern
  include Assets::Normalizer # normalize filename of paperclip attachment

  IMAGE_PROCESSING_IMAGE_URL =     ActionController::Base.helpers.asset_path('resizing_gears_fullsize.gif')
  THUMBNAIL_PROCESSING_IMAGE_URL = ActionController::Base.helpers.asset_path('resizing_gears_fullsize.gif')
  TILE_IMAGE_PROCESSING_PRIORITY = -10

  included do
    #validates_with Paperclip::Validators::AttachmentPresenceValidator, attributes: [:image], if: :require_images, message: "image is missing"

    #validates_with Paperclip::Validators::AttachmentPresenceValidator, attributes: [:thumbnail], if: :require_images

    #validates_with Paperclip::Validators::AttachmentSizeValidator,less_than: (2.5).megabytes, 
                                                #message: " the image is too large, please use a smaller file", 
                                                #attributes: [:image], 
                                                #if: :require_images

    validates_attachment_content_type           :image, 
                                                content_type: valid_image_mime_types, 
                                                message: invalid_mime_type_error
    # The ":default_url => ~~~" option was not needed for Capy 1.x, but then Capy2 came along and started skipping
    # cucumber features without giving a reason. Specifically, one scenario in a feature file would pass, but
    # all subsequent ones would just be skipped. No reason was given - just a "Skipped step" output for each step.
    #
    # The frustrating part was the all of the failing tests would pass if run individually.
    #
    # Turns out that Tiles always (well, almost always - see the next paragraph) require a corresponding thumbnail,
    # as witnessed by the "validates_with AttachmentPresenceValidator" above and the default for ':require_images'
    # being set to 'true' in the migration.
    #
    # However, the Factory for a Tile sets 'require_images' to 'false' => '/thumbnails/carousel/missing.png' and
    # '/thumbnails/hover/missing.png' were being generated (by Paperclip) for the default tile image path when one
    # wasn't provided in Test mode, which happened a lot because we normally don't care about the specific image.
    #
    # The fact that these 2 files do not exist never caused a problem in pre-Capy2 days, but with Capy2 they led to the
    # behavior described above, i.e. the first cuke scenario generated an "HTML 500 response code - Internal Server Error"
    # which had no effect on the test that spawned the error, but which would cause all subsequent steps to be skipped!
    #
    # BTW, none of this info appeared in the 'test.log' file; you have to set "Capybara.javascript_driver = :webkit_debug"
    # in 'support/env.rb' in order to see it.
    #
    # Can you say: WTF!!!!! (I sure can!)

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
                          processing_image_url: IMAGE_PROCESSING_IMAGE_URL, 
                          priority:             TILE_IMAGE_PROCESSING_PRIORITY

    process_in_background :thumbnail, 
                          processing_image_url: THUMBNAIL_PROCESSING_IMAGE_URL, 
                          priority:             TILE_IMAGE_PROCESSING_PRIORITY

  end

  def image_really_still_processing
    image_url = image.url
    image_processing || image_url.nil? || image_url == IMAGE_PROCESSING_IMAGE_URL
  end

  def thumbnail_really_still_processing
    thumbnail_url = thumbnail.url
    thumbnail_processing || thumbnail_url.nil? || thumbnail_url == THUMBNAIL_PROCESSING_IMAGE_URL
  end

  # need this function to set height of image place in ie8 while image is loading
  def full_size_image_height
    return nil if image_file_name.nil?

    height, width = if image_processing?
                      [484, 666]
                    else
                      [image.height, image.width]
                    end

    full_width = 600.0 # px for full size tile
    ( height * full_width / width ).to_i
  end

  module ClassMethods
    include ValidImageMimeTypes
    #include Paperclip
  end
end
