require "simplecov"
SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
ENV["AWS_SECRET_ACCESS_KEY"] ||= "fake_key"

require 'fileutils'

test_counter = 0

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'clearance/rspec'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Capybara::Screenshot.autosave_on_failure = false

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
Capybara.javascript_driver = :chrome
# Capybara.javascript_driver = :headless_chrome

##

RSpec.configure do |config|
  config.mock_with :mocha
  config.example_status_persistence_file_path = "#{Rails.root}/spec/specs_with_statuses.txt"
  config.infer_spec_type_from_file_location!

  # config.fail_fast = true

  config.before(:all) do
    log_file = Rails.root.join("log/test.log")
    File.truncate(log_file, 0) if File.exist?(log_file)
  end

  config.before(:each) do |example|
    ApplicationController.any_instance.stubs(:set_eager_caches).returns(true)

    Mixpanel::Tracker.stubs(:new).with(MIXPANEL_TOKEN, Mocha::ParameterMatchers::KindOf.new(Hash)).returns(FakeMixpanelTracker)
    FakeMixpanelTracker.clear_tracked_events
    path = example.metadata[:example_group][:file_path]
    test_counter +=1
    full_example_description = "Starting #{RSpec.current_example} "
    Rails.logger.info("\n#{'-'*80}\n#{full_example_description} #{test_counter}--#{path}\n#{'-' * (full_example_description.length)}")
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
