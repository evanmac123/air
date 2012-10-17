S3_CREDENTIALS = {
  :access_key_id     => 'AKIAJVBKNOIHHPUOUHYA',
  :secret_access_key => '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'
}

S3_AVATAR_BUCKET = ENV['AVATAR_BUCKET'] || 'hengage-avatars-development'
S3_TILE_BUCKET = ENV['TILE_BUCKET'] || 'hengage-tiles-development'
S3_TILE_THUMBNAIL_BUCKET = ENV['TILE_BUCKET'] || 'hengage-tiles-development'

TILE_OPTIONS           = {}
TILE_IMAGE_OPTIONS     = {}
TILE_THUMBNAIL_OPTIONS = {}

case Rails.env
when 'production', 'staging'
  TILE_OPTIONS = {
    :storage => :s3,
    :s3_protocol => 'https', 
    :s3_credentials => S3_CREDENTIALS, 
    :hash_secret => "Kid Sister Diary Secure"}
  TILE_IMAGE_OPTIONS[:path] = "/tiles/:id/:hash__:filename"
  TILE_THUMBNAIL_OPTIONS[:path] = "/tile_thumbnails/:id/:hash__:filename"
when 'test', 'development'
  # Use defaults of :storage => :filesystem
else
  raise 'Environment Not Found'
end
TILE_IMAGE_OPTIONS.merge!(TILE_OPTIONS)
TILE_THUMBNAIL_OPTIONS.merge!(TILE_OPTIONS)
