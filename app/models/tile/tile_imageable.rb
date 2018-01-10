module Tile::TileImageable
  extend ActiveSupport::Concern

  IMAGE_PROCESSING_URL =  ActionController::Base.helpers.asset_path("missing-search-image.png")
  TILE_IMAGE_PROCESSING_PRIORITY = -10
  MISSING_THUMBNAIL = "missing-tile-img-thumb.png"
  MISSING_PREVIEW = "missing-search-image.png"

  included do

    has_attached_file :image,
      {
        styles: {
          viewer: "666>"
        },
        default_style: :viewer,
        default_url: ->(attachment) { ActionController::Base.helpers.asset_path(MISSING_PREVIEW) },
        validate_media_type: false
      }.merge!(TILE_IMAGE_OPTIONS)
    validates_attachment_content_type :image, content_type: [/\Aimage\/.*\Z/, /\A*\/octet-stream\Z/]

    has_attached_file :thumbnail,
      {
        styles: {
          carousel:     "238x238#",
          email_digest: "190x160#"
        },
        default_style: :carousel,
        default_url: ->(attachment) { ActionController::Base.helpers.asset_path(MISSING_THUMBNAIL) },
        preserve_files: true,
        validate_media_type: false
      }.merge!(TILE_THUMBNAIL_OPTIONS)
    validates_attachment_content_type :thumbnail, content_type: [/\Aimage\/.*\Z/, /\A*\/octet-stream\Z/]

    process_in_background :image,
      processing_image_url: :processing_image_fallback,
      priority: TILE_IMAGE_PROCESSING_PRIORITY

    process_in_background :thumbnail,
      processing_image_url: :processing_image_fallback,
      priority: TILE_IMAGE_PROCESSING_PRIORITY
  end

  def processing_image_fallback
    remote_media_url || IMAGE_PROCESSING_URL
  end
end
