silence_warnings do
  require 'debugger'
end unless ENV['NO_DEBUGGER']

Health::Application.configure do

  require(Rails.root + 'config/initializers/sendgrid')

  # Settings specified here will take precedence over those in config/application.rb

  config.dev_tweaks.autoload_rules do
    keep :xhr  # Disables caching of ajax requests
  end

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  # config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = ENV['TEST_CACHING']

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  ########  ASSETS  ######################
  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  #########################################
  
  ##

  #config.action_mailer.delivery_method = :test
  # See https://github.com/ryanb/letter_opener for details.
  config.action_mailer.delivery_method = :letter_opener

  ActionMailer::Base.smtp_settings = {
    :user_name => SendGrid::DEV_USERNAME,
    :password => SendGrid::DEV_PASSWORD,
    :domain => "air.bo",
    :address => "smtp.sendgrid.net",
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
   }
end

