ENV['INSPECTLET_WID']="1234567890"
silence_warnings do
  begin
    require 'ruby-debug'
  rescue LoadError
  end
end unless ENV['NO_DEBUGGER']

# config/environments/test.rb

# ActiveSupport::Deprecation.debug = true #backtrace for deprecation warnings

Health::Application.configure do
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true
  config.log_level = :debug

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = ENV['TEST_CACHING']

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = true

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.action_mailer.default_url_options = { :host => 'www.example.com' }

	Rails.application.routes.default_url_options[:host] = 'www.example.com'

  FAKE_TWILIO_ACCOUNT_SID  = "12345"
  FAKE_TWILIO_AUTH_TOKEN   = "abcde"

  Twilio::Config.setup \
    :account_sid => FAKE_TWILIO_ACCOUNT_SID,
    :auth_token => FAKE_TWILIO_AUTH_TOKEN

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
