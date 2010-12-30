require 'copycopter_client/helper'

if defined?(ActionController::Base)
  ActionController::Base.send :include, CopycopterClient::Helper
end
if defined?(ActionView::Base)
  ActionView::Base.send :include, CopycopterClient::Helper
end

module CopycopterClient
  # Responsible for Rails initialization
  module Rails
    # Sets up the logger, environment, name, project root, and framework name
    # for Rails applications. Must be called after framework initialization.
    def self.initialize
      CopycopterClient.configure(false) do |config|
        config.environment_name = ::Rails.env
        config.logger           = ::Rails.logger
        config.framework        = "Rails: #{::Rails::VERSION::STRING}"
        config.fallback_backend = I18n.backend
      end
    end
  end
end

if defined?(Rails::Railtie)
  require 'copycopter_client/railtie'
else
  CopycopterClient::Rails.initialize
end

