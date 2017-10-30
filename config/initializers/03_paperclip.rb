case Rails.env
when 'production', 'staging', 'production_local'
  Paperclip::Attachment.default_options.merge!(
    {
      storage: :s3,
      s3_protocol: 'https',
      s3_credentials: S3_CREDENTIALS,
      s3_headers: {
        'Expires' => 1.year.from_now.httpdate,
        'Cache-Control' => 'max-age=315576000'
      },
      bucket: APP_BUCKET,
      url: ":s3_domain_url",
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
    bucket: S3_LOGO_BUCKET
  }

  TOPIC_BOARD_OPTIONS = {
    path: "/topic_board/:id/:hash__:filename",
    bucket: S3_LOGO_BUCKET
  }

  USER_AVATAR_OPTIONS = {
    path: "/avatars/:id/:style/:filename",
    bucket: S3_AVATAR_BUCKET
  }

when 'test',  'development'

  Paperclip::Attachment.default_options.merge!(
    {
      url: "/system/:rails_env/:class/:attachment/:id/:style/:filename",
    }
  )

  #We need these because because they were originally implemented with custom paths. If we want to move away from the custom pattern, we can do a mass S3 sync. Also, if we want to move away from the merge pattern in the modals for Paperclip, we likely have to setup a mock S3 for dev.

  TILE_IMAGE_OPTIONS = {}
  TILE_THUMBNAIL_OPTIONS = {}
  DEMO_LOGO_OPTIONS = {}
  TOPIC_BOARD_OPTIONS = {}
  USER_AVATAR_OPTIONS = {}
else
  raise 'Environment Not Found'
end
