S3_CREDENTIALS = {
  :access_key_id     => (ENV['AWS_ACCESS_KEY_ID'] ),
  :secret_access_key => (ENV['AWS_SECRET_ACCESS_KEY'])
}

S3_AVATAR_BUCKET = ENV['AVATAR_BUCKET'] || 'hengage-avatars-development'
S3_TILE_BUCKET = ENV['TILE_BUCKET'] || 'hengage-tiles-development'
S3_TILE_THUMBNAIL_BUCKET = ENV['TILE_BUCKET'] || 'hengage-tiles-development'
S3_LOGO_BUCKET = ENV['LOGO_BUCKET'] || 'hengage-logos-development'

TILE_IMAGE_OPTIONS     = {}
TILE_THUMBNAIL_OPTIONS = {}
DEMO_LOGO_OPTIONS = {}

case Rails.env
when 'production', 'staging', "production_local"
  TILE_OPTIONS = {
    :storage => :s3,
    :s3_protocol => 'https', 
    :s3_credentials => S3_CREDENTIALS,
    :s3_headers => {'Expires' => 1.year.from_now.httpdate, 'Cache-Control' => 'max-age=315576000'},
    :hash_data => "tiles/:attachment/:id/:style/:updated_at",
    :hash_secret => "Kid Sister Diary Secure",
    :url            => ":s3_domain_url"}

  TILE_IMAGE_OPTIONS[:path] = "/tiles/:id/:hash__:filename"
  TILE_THUMBNAIL_OPTIONS[:path] = "/tile_thumbnails/:id/:hash__:filename"
  LOGO_OPTIONS = {
    :storage => :s3,
    :s3_protocol => 'https', 
    :s3_credentials => S3_CREDENTIALS,
    :s3_headers => {'Expires' => 1.year.from_now.httpdate, 'Cache-Control' => 'max-age=315576000'},
    :hash_data => "demos/:attachment/:id/:style/:updated_at",
    :hash_secret => "Kid Sister Diary Secure",
    :url            => ":s3_domain_url"
  }
  DEMO_LOGO_OPTIONS[:path] = "/demo/:id/:hash__:filename"
when 'test',  'development'
  # Use defaults of :storage => :filesystem
else
  raise 'Environment Not Found'
end

TILE_OPTIONS ||= {}
TILE_IMAGE_OPTIONS.merge!(TILE_OPTIONS)
TILE_THUMBNAIL_OPTIONS.merge!(TILE_OPTIONS)

LOGO_OPTIONS ||= {}
DEMO_LOGO_OPTIONS.merge!(LOGO_OPTIONS)
