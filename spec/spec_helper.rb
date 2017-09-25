require "simplecov"
SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
ENV["AWS_SECRET_ACCESS_KEY"] ||= "fake_key"

require 'fileutils'

test_counter = 0

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'clearance/rspec'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Capybara::Screenshot.autosave_on_failure = false

## Poltergeist Configuration
#### If you'd like to run a feature spec in debug mode, change the Capybara js driver to :poltergeist_debug and you can insert page.driver.debug into your tests to pause the test and launch a browser which gives you the inspector to view your test run with.

Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, inspector: true)
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { js_errors: false,  window_size: [1920, 6000] })
end

Capybara.javascript_driver = :poltergeist
# Capybara.javascript_driver = :poltergeist_debug
# Capybara.javascript_driver = :selenium


##

RSpec.configure do |config|
  config.mock_with :mocha
  config.example_status_persistence_file_path = "#{Rails.root}/spec/specs_with_statuses.txt"
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
    Twilio::TwiML::MessagingResponse.stubs(:new).returns(FakeTwilio::TwiMLResponse.new)

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
