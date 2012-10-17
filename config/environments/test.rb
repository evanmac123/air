silence_warnings do
  begin
    require 'pry'
    IRB = Pry
  rescue LoadError
  end

  begin
    require 'ruby-debug'
  rescue LoadError
  end
end unless ENV['NO_DEBUGGER']
  
Health::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  #
  ######################## Caching Models, etc.     ###################
  # Cache classes needs to be false when running Spork, or the models  #
  # will not get reloaded in between test attempts. However,           #
  # when not using spork it (should) run faster if caching is true     # 
  # By the way, ENV['DRB'] is something that is set when spork is used #
  config.cache_classes = ENV['DRB'].nil?                               #
  ######################################################################

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

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
    
end

