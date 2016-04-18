require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'mobvious'
require 'htmlentities'
require File.expand_path(__FILE__ + '/../../app/middleware/request_timestamp')


# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production,use this line
  # Bundler.require(:default, :assets, Rails.env)
end

DEFAULT_DEMO_PARENT_BOARD = ENV['DEFAULT_DEMO_PARENT_BOARD'] || "healthplanbasics"

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
      app-admin.css
      app-client-admin.css
      app-client-admin_split2.css
      app-client-admin_split3.css
      client_admin_base.css
      app-external.css
      app-internal.css
      app-internal_split2.css
      app-internal_split3.css
      app-internal_split4.css
      app-internal_split5.css
      app-landing.css
      app-user-progress.css
      app-user-progress_split2.css
      styleguide.css
      vendor/ie8-grid16-foundation-4.css
      vendor/ie8-grid12-foundation-4.css
      external/external_ie8.css
      external/standalone_ie8.css
      internal/internal_ie8.css
      client_admin/client_admin_ie8.css
      app-support.css
      public_board_fixed_headers.css
      public_board_fixed_headers.js
      app-admin.js
      app-internal.js
      app-external.js
      app-landing.js
      app-pages.js
      app-client-admin.js
      for-modern-browsers.js
      file-uploader.js
      client_admin/add_new_item_via_select.js
      errors.css
      external/blog_rss.js
      external/textscroll.js
      external/join.js
      external/marketing_nav.js
      external/prefilled_input.js
      jquery.lightbox_me.js
      rem.min.js
      flick/jquery-ui-1.8.10.custom.css
      ga.js
      ga-marketing.js
      admin/byte_counter.js
      resizing_gears_fullsize.gif
      internal/guest_user_conversion.js
      client_admin/public_board_controls.js
      app-support.js
      internal/explore.css
      Explore_tile_page/antioxidents.png
      Explore_tile_page/drink_water.png
      Explore_tile_page/happy_smile.png
      Explore_tile_page/cholesterol.png
      Explore_tile_page/relationships.png
      Explore_tile_page/recycle_yourself.png
      Explore_tile_page/notebook.png
      Explore_tile_page/open_book.png
      client_admin/tile_tag_callback.js
      internal/countUp.min.js
      internal/point_and_ticket_animation.js
      internal/validate_new_board.js
    )

    ################################################################

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    config.autoload_paths += %W(#{Rails.root}/app/presenters/board_settings #{config.root}/app/presenters/digest #{config.root}/app/presenters/explores #{config.root}/app/presenters/tile_preview)

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

    config.middleware.use RequestTimestamp

    # Allows us to detect the type of client device on the server, i.e. before sending the page down
    config.middleware.use Mobvious::Manager

    # Compresses response bodies
    config.middleware.use Rack::Deflater

    redis_cache_expiration = ENV['REDIS_CACHE_EXPIRATION'].try(:to_i) || 10.years
    config.cache_store = :redis_store, ENV['REDISTOGO_URL'], { expires_in: redis_cache_expiration }
  end
end
