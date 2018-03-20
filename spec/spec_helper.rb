require "simplecov"
SimpleCov.start
SCOUT_MONITOR=false
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
ENV["AWS_SECRET_ACCESS_KEY"] ||= "fake_key"

require 'fileutils'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'paperclip/matchers'
require 'clearance/rspec'
require 'capybara/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu) }
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver :firefox do |app|
  Capybara::Selenium::Driver.new(app, browser: :firefox)
end

# Capybara.javascript_driver = :firefox
# Capybara.javascript_driver = :chrome
Capybara.javascript_driver = :headless_chrome

##

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Paperclip::Shoulda::Matchers
  config.example_status_persistence_file_path = "#{Rails.root}/spec/specs_with_statuses.txt"
  config.infer_spec_type_from_file_location!

  config.before(:all) do
    log_file = Rails.root.join("log/test.log")
    File.truncate(log_file, 0) if File.exist?(log_file)
  end

  config.before(:each) do |example|
    ApplicationController.any_instance.stubs(:set_eager_caches).returns(true)

    Mixpanel::Tracker.stubs(:new).with(MIXPANEL_TOKEN, Mocha::ParameterMatchers::KindOf.new(Hash)).returns(FakeMixpanelTracker)
    FakeMixpanelTracker.clear_tracked_events
  end

  config.before(:each) do
    User::SegmentationData.delete_all
    User::SegmentationResults.delete_all
    $redis.flushdb
    $redis_bulk_upload.flushdb
  end

  config.before(:each) do
    $twilio_client = FakeTwilio::Client.new
    FakeTwilio::Client.messages = []
  end

  config.after(:suite) do
    FileUtils.rm_rf "#{Rails.root}/public/system/test"
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    # Choose one or more libraries:
    with.library :active_record
    with.library :active_model
    with.library :action_controller
    # Or, choose the following (which implies all of the above):
    with.library :rails
  end
end

module Paperclip
  def self.run(cmd, params = "", expected_outcodes = 0)
    case cmd
    when "identify"
      Rails.logger.info("!!!stubs identify")
      return "100x100"
    when "convert"
      Rails.logger.info("!!!!stubs Convert")
      return
    else
      super
    end
  end

  class Attachment
    def post_process
    end
  end
end
