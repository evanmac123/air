require "cover_me"

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'clearance/testing'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :mocha

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before(:each) do
    Mixpanel::Tracker.stubs(:new).with(MIXPANEL_TOKEN, Mocha::ParameterMatchers::KindOf.new(Hash)).returns(FakeMixpanelTracker)
    FakeMixpanelTracker.clear_tracked_events
  end

  config.before(:each) do
    User::SegmentationData.delete_all
    User::SegmentationResults.delete_all
  end

  config.before(:each) do
    FakeTwilio.clear_messages
  end
end

# Big Fat Hack (TM) so the ActiveRecord connections are shared across threads.
# This is a variation of a hack you can find all over the web to make
# capybara usable without having to switch to non transactional
# fixtures.
# http://groups.google.com/group/ruby-capybara/browse_thread/thread/248e89ae2acbf603/e5da9e9bfac733e0
Thread.main[:activerecord_connection] = ActiveRecord::Base.retrieve_connection

def (ActiveRecord::Base).connection
  Thread.main[:activerecord_connection]
end

require 'capybara-webkit'
Capybara.javascript_driver = :webkit

# Hack to allow us to use regular controller tests to test SmsController 
# (which is an ActionController::Metal).

def metal_testing_hack(klass)
  klass.class_eval do
    include ActionController::UrlFor
    include ActionController::Testing
    include Rails.application.routes.url_helpers
  end
end

require 'ruby-debug'
Rails.logger.level = 4
