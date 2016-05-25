HOMEPAGE_BOARD_SLUGS = ENV['HOMEPAGE_BOARD_SLUGS'] || "wellness-starter-kit,healthplanbasics,internal-validation,airbo-2"
ENV['INSPECTLET_WID']="1234567890"
Health::Application.configure do

  require(Rails.root + 'config/initializers/sendgrid')

  # Settings specified here will take precedence over those in config/application.rb

  config.dev_tweaks.autoload_rules do
    keep :xhr  # Disables caching of ajax requests
  end

  config.generators do |g|
    g.template_engine :erb
    g.stylesheets = false
    g.javascripts = false
    g.helper = false
    g.assets = false
    g.fixtures = false
    g.view_specs false
    g.routing_specs false
    g.controller_specs false
    g.helper_specs false
    g.decorator false
    g.factories false
  end

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  config.reload_classes_only_on_change= true

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

Rails.application.routes.default_url_options[:host] = ENV['APP_HOST'] || 'localhost:3000'
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
    :domain => "airbo.com",
    :address => "smtp.sendgrid.net",
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
   }
end

