

case Rails.env
when 'production', 'staging', "production_local"

  Paperclip::Attachment.default_options.merge!(
    {
      storage: :s3,
      s3_protocol: 'https',
      s3_credentials: S3_CREDENTIALS,
      s3_headers: {'Expires' => 1.year.from_now.httpdate, 'Cache-Control' => 'max-age=315576000'},
      url:         ":s3_domain_url",
      hash_secret: "Kid Sister Diary Secure",
      hash_data: ":class/:attachment/:id/:style/:updated_at",
      path: ":class/:id/:filename"
    }
  )

  TILE_IMAGE_OPTIONS = {
    path: "/tiles/:id/:hash__:filename",
    hash_data: "tiles/:attachment/:id/:style/:updated_at"
  }

  TILE_THUMBNAIL_OPTIONS = {
    path: "/tile_thumbnails/:id/:hash__:filename",
    hash_data: "tiles/:attachment/:id/:style/:updated_at"
  }

  DEMO_LOGO_OPTIONS = {
    path: "/demo/:id/:hash__:filename",
  }

#deprecate the rest of these:
  TOPIC_OPTIONS = {
    path: "/topic/:id/:hash__:filename",
  }

  TOPIC_BOARD_OPTIONS = {
    path: "/topic_board/:id/:hash__:filename",
  }

when 'test',  'development'

  Paperclip::Attachment.default_options.merge!(
    {
      storage: :fog,
      fog_credentials: {
        provider: "Local",
        local_root: "#{Rails.root}/public/system/attachments/#{Rails.env}"
      },
      fog_directory: "",
      fog_host: "http://localhost:3000/system/attachments/#{Rails.env}",
      path: ":class/:id/:filename",
    }
  )

  #these need custom paths because the calling class is not the model
  TILE_IMAGE_OPTIONS = {
    path: "/tiles/:id/:filename",
  }

  TILE_THUMBNAIL_OPTIONS = {
    path: "/tile_thumbnails/:id/:filename",
  }

#deprecate teh rest of these:
  DEMO_LOGO_OPTIONS = {
    path: "demo/:id/:filename",
  }

#deprecate teh rest of these:
  TOPIC_OPTIONS = {
    path: "topic/:id/:filename",
  }

  TOPIC_BOARD_OPTIONS = {
    path: "topic_board/:id/:filename",
  }

else
  raise 'Environment Not Found'
end
