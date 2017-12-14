require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require 'mobvious'
require 'htmlentities'
require File.expand_path(__FILE__ + '/../../app/middleware/request_timestamp')

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Health
  class Application < Rails::Application
    config.generators do |generate|
      generate.test_framework :rspec
    end

    ###################  ASSET PIPELINE  ###########################
    # Enable the asset pipeline
    config.assets.enabled = true
    # Tell heroku not to try to talk to the mongo database while it precompiles assets
    config.assets.initialize_on_precompile = false
    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '0.0.3'
    config.assets.paths += Dir["#{Rails.root}/vendor/assets/stylesheets"].sort_by { |dir| -dir.size }
    # Tell rake which assets to precompile (default is application.css and application.js)
    # Note that even though our files are named .scss, the ones in this list are the plain .css counterparts
    config.assets.precompile += %w(
      app-marketing-site.css
      app-admin.css
      app-client-admin.css
      app-external.css
      app-internal.css
      app-landing.css
      external/external_ie8.css
      internal/internal_ie8.css
      client_admin/client_admin_ie8.css

      application.js
      app-user.js
      app-admin.js
      app-marketing-site.js
    )


    ################################################################

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    config.autoload_paths += %W(
      #{Rails.root}/app/presenters/board_settings #{config.root}/app/presenters/digest #{config.root}/app/presenters/tile_preview
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
    )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    config.action_view.javascript_expansions[:defaults] = %w()

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Add this block so mongo doesn't scream when we do a rails migration
    # Reference: http://groups.google.com/group/mongoid/browse_thread/thread/df278a11dba4d331?pli=1
    config.generators do |g|
      g.orm :active_record
    end

    config.middleware.use RequestTimestamp

    # Allows us to detect the type of client device on the server, i.e. before sending the page down
    config.middleware.use Mobvious::Manager

    # Compresses response bodies
    config.middleware.use Rack::Deflater

    config.cache_store = :redis_store, ENV['REDIS_CACHE'], { expires_in: 5.years }

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end
  end
end
