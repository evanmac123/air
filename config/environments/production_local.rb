Health::Application.configure do
  require(Rails.root + 'config/initializers/sendgrid')
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # Note that you must run 
  # heroku labs:enable user_env_compile --app <appname>
  # In order for assets to be compiled during push
  # config.action_controller.asset_host = "//#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com"
  # config.action_mailer.asset_host = "https:" + config.action_controller.asset_host

	Rails.application.routes.default_url_options[:host] = ENV['APP_HOST'] || 'localhost:3000'
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  
  ############  ASSETS   ###############
  config.assets.enabled = true

  # Compress JavaScript and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true
  #######################################
  
  config.action_mailer.delivery_method = :letter_opener

  ActionMailer::Base.smtp_settings = {
    :user_name => SendGrid::DEV_USERNAME,
    :password => SendGrid::DEV_PASSWORD,
    :domain => "airbo.com",
    :address => "smtp.sendgrid.net",
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
   }
  
end
