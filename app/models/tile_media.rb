class TileMedia < ActiveRecord::Base
  #TODO consider deleting this file and related db elements if will not use
  include Concerns::TileImageable
  belongs_to :tile
  attr_accessible :processed, :remote_url, :upload


    validates_with Paperclip::Validators::AttachmentPresenceValidator, attributes: [:document], if: :require_images, 
                                                message: "image is missing"

    validates_with Paperclip::Validators::AttachmentSizeValidator,     less_than: (2.5).megabytes, 
                                                message: " the image is too large, please use a smaller file", 
                                                attributes: [:image], 
                                                if: :require_images

    validates_attachment_content_type           :image, 
                                                content_type: valid_image_mime_types, 
                                                message: invalid_mime_type_error



has_attached_file :document,
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



end
