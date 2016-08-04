require 'rubygems'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
ENV["AWS_SECRET_ACCESS_KEY"] ||= "fake_key"

require 'fileutils'

test_counter = 0

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'clearance/testing'
require 'rspec/autorun'
require 'mocha/setup'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'

Capybara::Screenshot.autosave_on_failure = false
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

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
 Capybara::Poltergeist::Driver.new(app, timeout: 600, block_unknown_urls: true)
end

Capybara.register_driver :webkit do |app|
  Capybara::Webkit.configure do |config|
    config.block_unknown_urls
  end
  Capybara::Webkit::Driver.new(app, timeout: 600, block_unknown_urls: true)
end


ActiveRecord::Base.logger = nil

RSpec.configure do |config|
  config.mock_with :mocha
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.use_transactional_fixtures = false
  #config.fail_fast = true

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
  config.before(:all) do
    log_file = Rails.root.join("log/test.log")
    File.truncate(log_file, 0) if File.exist?(log_file)
    Delayed::Worker.delay_jobs = false
  end

  config.before(:each) do
    Mixpanel::Tracker.stubs(:new).with(MIXPANEL_TOKEN, Mocha::ParameterMatchers::KindOf.new(Hash)).returns(FakeMixpanelTracker)
    FakeMixpanelTracker.clear_tracked_events
    path = example.metadata[:example_group][:file_path]
    test_counter +=1
    full_example_description = "Starting #{self.example.description} "
    Rails.logger.info("\n#{'-'*80}\n#{full_example_description} #{test_counter}--#{path}\n#{'-' * (full_example_description.length)}")
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

  config.after(:suite) do
   FileUtils.rm_rf "#{LOCAL_FILE_ATTACHMENT_BASE_PATH}/test"
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

# Hack to allow us to use regular controller tests to test, among others, SmsController
# (which is an ActionController::Metal).

def metal_testing_hack(klass)
  klass.class_eval do
    include ActionController::UrlFor
    include ActionController::Testing
    include Rails.application.routes.url_helpers
  end
end
