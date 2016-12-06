

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

  ATTACHMENT_CONFIG_BASE = {}

  TILE_IMAGE_OPTIONS = {
    path: "/tiles/:id/:hash__:filename",
    hash_data: "tiles/:attachment/:id/:style/:updated_at"
  }

  TILE_THUMBNAIL_OPTIONS = {
    path: "/tile_thumbnails/:id/:hash__:filename",
    hash_data: "tiles/:attachment/:id/:style/:updated_at"
  }

#deprecate the rest of these:
  DEMO_LOGO_OPTIONS = {
    path: "/demo/:id/:hash__:filename",
  }

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
      hash_secret: "Kid Sister Diary Secure",
      path: ":class/:id/:filename",
    }
  )

  #attachement_config_base is a poor pattern.  Begin replacing with config.paperclip_defaults in environments/*.rb
  ATTACHMENT_CONFIG_BASE = {}
  
  #these need custom paths because the calling class is not the model
  TILE_IMAGE_OPTIONS = {
    path: "/tiles/:id/:hash__:filename",
  }

  TILE_THUMBNAIL_OPTIONS = {
    path: "/tile_thumbnails/:id/:hash__:filename",
  }

#deprecate teh rest of these:
  DEMO_LOGO_OPTIONS = {
    path: "demo/:id/:hash__:filename",
  }

  TOPIC_OPTIONS = {
    path: "topic/:id/:hash__:filename",
  }

  TOPIC_BOARD_OPTIONS = {
    path: "topic_board/:id/:hash__:filename",
  }

else
  raise 'Environment Not Found'
end

# TILE_IMAGE_OPTIONS.merge!(ATTACHMENT_CONFIG_BASE)
# TILE_THUMBNAIL_OPTIONS.merge!(ATTACHMENT_CONFIG_BASE)
# DEMO_LOGO_OPTIONS.merge!(ATTACHMENT_CONFIG_BASE)
# TOPIC_OPTIONS.merge!(ATTACHMENT_CONFIG_BASE)
# TOPIC_BOARD_OPTIONS.merge!(ATTACHMENT_CONFIG_BASE)
