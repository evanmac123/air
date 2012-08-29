require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production,use this line
  # Bundler.require(:default, :assets, Rails.env)
end


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
    
    # Tell rake which assets to precompile (default is application.css and application.js)
    # Note that even though our files are named .scss, the ones in this list are the plain .css counterparts
    config.assets.precompile += %w(
      application-base.css
      application-ie7.css
      application-ie8.css
      admin/segmentation.css
      admin/targeted_messages.css
      external/marketing.css
      ga.js
      ga-marketing.js
      sign_in.js
    )

    ################################################################
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
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
  end
end
