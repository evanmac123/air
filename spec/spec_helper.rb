require 'rubygems'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
ENV["AWS_SECRET_ACCESS_KEY"] ||= "fake_key"
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'clearance/testing'
require 'rspec/autorun'
require 'mocha/setup'
require 'capybara/poltergeist'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.use_transactional_fixtures = false

  config.around(:each) do |example|
    # It should do all of this automatically. Want to bet on whether it does or not?
    if example.metadata[:driver]
      Capybara.current_driver = example.metadata[:driver]
    elsif example.metadata[:js]
      Capybara.current_driver = :poltergeist
    end

    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :deletion, {pre_count: true}
    end

    DatabaseCleaner.cleaning do
      example.run
    end

    Capybara.use_default_driver
  end

  config.before(:each) do
    Mixpanel::Tracker.stubs(:new).with(MIXPANEL_TOKEN, Mocha::ParameterMatchers::KindOf.new(Hash)).returns(FakeMixpanelTracker)
    FakeMixpanelTracker.clear_tracked_events
  end

  config.before(:each) do
    User::SegmentationData.delete_all
    User::SegmentationResults.delete_all
  end

  config.before(:each) do
    begin
      FakeTwilio.clear_messages
    rescue NameError => e # quietly ignore if FakeTwilio not loaded
    end
  end

  # handy if you've got a test that hangs
  #config.before(:each) do
    #puts example.metadata[:description]
  #end
end

# Regarding Poltergeist vs. Capy-Webkit: We prefer the former over the latter for JS testing.
# However, there are some tests that work fine with Webkit but not with Poltergeist.
# Rather than shave that yak, you can use Webkit on a single scenario by giving the options
# js: true, driver: :webkit.

Capybara.javascript_driver = :poltergeist

# Uncomment these lines for debug output
#Capybara.register_driver :poltergeist do |app|
#  Capybara::Poltergeist::Driver.new(app, debug: true)
#end
Capybara.register_driver :poltergeist do |app|
 Capybara::Poltergeist::Driver.new(app, timeout: 600)
end
Capybara.register_driver :webkit do |app|
 Capybara::Webkit::Driver.new(app, timeout: 600)
end

require 'capybara-screenshot/rspec'
Capybara::Screenshot.autosave_on_failure = false

# Hack to allow us to use regular controller tests to test, among others, SmsController
# (which is an ActionController::Metal).

def metal_testing_hack(klass)
  klass.class_eval do
    include ActionController::UrlFor
    include ActionController::Testing
    include Rails.application.routes.url_helpers
  end
end

Rails.logger.level = 4
