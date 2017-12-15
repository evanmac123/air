require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "mobvious"
require File.expand_path(__FILE__ + "/../../app/middleware/request_timestamp")

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Health
  class Application < Rails::Application
    ###################  ASSET PIPELINE  ###########################
    config.assets.paths += Dir["#{Rails.root}/vendor/assets/stylesheets"].sort_by { |dir| -dir.size }

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
      #{config.root}/app/presenters/digest
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
    )


    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

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


    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end
  end
end
