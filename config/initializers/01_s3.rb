S3_CREDENTIALS = {
  :access_key_id     => (ENV['AWS_ACCESS_KEY_ID'] ),
  :secret_access_key => (ENV['AWS_SECRET_ACCESS_KEY'])
}

S3_AVATAR_BUCKET = ENV['AVATAR_BUCKET'] || 'hengage-avatars-development'
S3_TILE_BUCKET = ENV['TILE_BUCKET'] || 'hengage-tiles-development'
S3_TILE_THUMBNAIL_BUCKET = ENV['TILE_BUCKET'] || 'hengage-tiles-development'
S3_LOGO_BUCKET = ENV['LOGO_BUCKET'] || 'hengage-logos-development'

