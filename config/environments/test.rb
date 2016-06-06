ENV['INSPECTLET_WID']="1234567890"
silence_warnings do
  begin
    require 'ruby-debug'
  rescue LoadError
  end
end unless ENV['NO_DEBUGGER']

# config/environments/test.rb
class ClearanceBackDoor
  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    sign_in_through_the_back_door
    @app.call(@env)
  end

  private

  def sign_in_through_the_back_door
    if user_id = params['as']
      user = User.find_by_slug(user_id)
      @env[:clearance].sign_in(user)
    end
  end

  def params
    Rack::Utils.parse_query(@env['QUERY_STRING'])
  end
end

module Airbrake

  def self.notify e
    #Do Nothing
  end

end


Health::Application.configure do
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

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

  config.middleware.use ClearanceBackDoor

  config.action_mailer.asset_host = "//example.com"
end
