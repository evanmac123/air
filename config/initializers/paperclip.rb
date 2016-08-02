

case Rails.env
when 'production', 'staging', "production_local"

  ATTACHMENT_CONFIG_BASE = {
    :storage => :s3,
    :s3_protocol => 'https', 
    :s3_credentials => S3_CREDENTIALS,
    :s3_headers => {'Expires' => 1.year.from_now.httpdate, 'Cache-Control' => 'max-age=315576000'},
    :url            => ":s3_domain_url",
    :hash_secret => "Kid Sister Diary Secure",
  }

  TILE_IMAGE_OPTIONS = {
    path: "/tiles/:id/:hash__:filename"
  }

  TILE_THUMBNAIL_OPTIONS = {
    path: "/tile_thumbnails/:id/:hash__:filename",
    hash_data:  "tiles/:attachment/:id/:style/:updated_at",
  }

  DEMO_LOGO_OPTIONS = {
    path: "/demo/:id/:hash__:filename",
    hash_data:  "demos/:attachment/:id/:style/:updated_at",
  }

when 'test',  'development'

  LOCAL_FILE_ATTACHMENT_BASE_PATH = "public/system/attachments"

  ATTACHMENT_CONFIG_BASE = {}

  TILE_IMAGE_OPTIONS     = {
    path: "#{LOCAL_FILE_ATTACHMENT_BASE_PATH}/#{Rails.env}/tiles/:id/:filename"
  }

  TILE_THUMBNAIL_OPTIONS = {
    path: "#{LOCAL_FILE_ATTACHMENT_BASE_PATH}/#{Rails.env}/tile_thumbnails/:id/:filename",
  }

  DEMO_LOGO_OPTIONS = {
    path: "#{LOCAL_FILE_ATTACHMENT_BASE_PATH}/#{Rails.env}/demo/:id/:filename",
  }

else
  raise 'Environment Not Found'
end

TILE_IMAGE_OPTIONS.merge!(ATTACHMENT_CONFIG_BASE)
TILE_THUMBNAIL_OPTIONS.merge!(ATTACHMENT_CONFIG_BASE)
DEMO_LOGO_OPTIONS.merge!(ATTACHMENT_CONFIG_BASE)
