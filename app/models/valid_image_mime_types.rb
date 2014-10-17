module ValidImageMimeTypes
  VALID_IMAGE_MIME_TYPES = ["image/bmp", "image/x-windows-bmp", "image/gif", "image/jpeg", "image/pjpeg", "image/x-portable-bmp", "image/png"].freeze
  INVALID_MIME_TYPE_ERROR = "that doesn't look like an image file. Please use a file with the extension .jpg, .jpeg, .gif, .bmp or .png.".freeze

  def valid_image_mime_types
    VALID_IMAGE_MIME_TYPES
  end
  
  def invalid_mime_type_error
    INVALID_MIME_TYPE_ERROR
  end
end
