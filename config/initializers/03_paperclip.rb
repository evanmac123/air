case Rails.env
when 'production', 'staging', "production_local"
  Paperclip::Attachment.default_options.merge!(
    {
      storage: :s3,
      s3_protocol: 'https',
      s3_credentials: S3_CREDENTIALS,
      s3_headers: {'Expires' => 1.year.from_now.httpdate, 'Cache-Control' => 'max-age=315576000'},
      bucket: APP_BUCKET,
      url:         ":s3_domain_url",
      hash_secret: "Kid Sister Diary Secure",
      path: ":class/:attachment/:id/:style/:filename"
    }
  )

  TILE_IMAGE_OPTIONS = {
    path: "/tiles/:id/:hash__:filename",
    hash_data: "tiles/:attachment/:id/:style/:updated_at",
    bucket: S3_TILE_BUCKET
  }

  TILE_THUMBNAIL_OPTIONS = {
    path: "/tile_thumbnails/:id/:hash__:filename",
    hash_data: "tiles/:attachment/:id/:style/:updated_at",
    bucket: S3_TILE_THUMBNAIL_BUCKET
  }

  DEMO_LOGO_OPTIONS = {
    path: "/demo/:id/:hash__:filename",
  }

  TOPIC_BOARD_OPTIONS = {
    path: "/topic_board/:id/:hash__:filename",
    bucket: S3_LOGO_BUCKET
  }

when 'test',  'development'

  Paperclip::Attachment.default_options.merge!(
    {
      url: "/system/:rails_env/:class/:attachment/:id/:style/:filename",
      default_url: ":rails_root/assets/images/airbo_character_hi.png"
    }
   )

  #these need custom paths because the calling class is not the model
  TILE_IMAGE_OPTIONS = {}

  TILE_THUMBNAIL_OPTIONS = {}

  DEMO_LOGO_OPTIONS = {}

  TOPIC_BOARD_OPTIONS = {}
else
  raise 'Environment Not Found'
end
