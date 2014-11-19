begin
  AssetSync.configure do |config|
    config.fog_provider = 'AWS'
    config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
    config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    config.fog_directory = ENV['FOG_DIRECTORY']
    
    # Increase upload performance by configuring your region
    # config.fog_region = 'eu-west-1'
    #
    # Uncommenting this will force a re-upload of all assets, which comes in
    # handy once in a while, but takes forever.
    #config.existing_remote_files = "ignore"
    #
    # Automatically replace files with their equivalent gzip compressed version
    # config.gzip_compression = true
    #
    # Use the Rails generated 'manifest.yml' file to produce the list of files to 
    # upload instead of searching the assets directory.
    # config.manifest = true
    #
    # Fail silently.  Useful for environments such as Heroku
    config.fail_silently = true

    # Set long-lived expiration
    config.custom_headers = { '.*' => { cache_control: 'max-age=315576000', expires: 1.year.from_now.httpdate } }
  end
rescue NameError
end
