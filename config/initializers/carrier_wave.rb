BULK_UPLOADER_BUCKET = ENV['BULK_UPLOADER_BUCKET'] || "airbo-bulk-uploads-#{Rails.env}".freeze

CarrierWave.configure do |config|
  access_key_id = if Rails.env.test?
                    'TEST_ACCESS_KEY_ID'
                  else
                    ENV['AWS_BULK_UPLOAD_ACCESS_KEY_ID'] || "fake_access_key_id"
                  end

  secret_key =    if Rails.env.test?
                    'TEST_SECRET_ACCESS_KEY'
                  else
                    ENV['AWS_BULK_UPLOAD_SECRET_ACCESS_KEY'] || "fake_access_key_id"
                  end

  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => access_key_id,
    :aws_secret_access_key  => secret_key
  }
  config.fog_directory  = BULK_UPLOADER_BUCKET # required
  config.fog_public     = false
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
end
