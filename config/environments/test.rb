Rails.application.configure do
  config.cache_classes = true

  config.log_level = :debug

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = true

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.action_mailer.default_url_options = { :host => 'www.example.com' }

	Rails.application.routes.default_url_options[:host] = 'www.example.com'

  #########  ASSETS   ##################################################################
  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Allow pass debug_assets=true as a query parameter to load pages with unpackaged assets
  config.assets.allow_debugging = true
  ##########################################################################################

  config.middleware.use Clearance::BackDoor do |slug|
    Clearance.configuration.user_model.find_by_slug(slug)
  end

  config.action_mailer.asset_host = "//example.com"

  config.cache_store = :redis_store, { host: "localhost", port: 6379, db: 15 }

  Paperclip.options[:log] = false
end
