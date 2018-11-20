                                   # Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '0.0.3'

# Add additional assets to the asset load path
Rails.application.config.assets.paths += Dir["#{Rails.root}/vendor/assets/stylesheets"].sort_by { |dir| -dir.size }
Rails.application.config.assets.paths << Rails.root.join("vendor", "assets", "images", "videos")

Rails.application.config.assets.paths << "#{Rails.root}/app/assets/videos"

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
Rails.application.config.assets.precompile += %w(
  app-marketing-site.css
  app-admin.css
  app-client-admin.css
  app-external.css
  app-internal.css
  app-landing.css
  app-form.css
  app-product.css
  external/external_ie8.css
  internal/internal_ie8.css
  client_admin/client_admin_ie8.css
  application.js
  app-user.js
  app-admin.js
  app-marketing-site.js
)
