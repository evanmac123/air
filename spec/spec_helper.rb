require 'rubygems'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'clearance/testing'
require 'rspec/autorun'
require 'mocha/setup'
#require 'draper/test/rspec_integration'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # These three were recommended in railscast #285 (Spork)
  #config.treat_symbols_as_metadata_keys_with_true_values = true
  #config.filter_run :focus => true
  #config.run_all_when_everything_filtered = true


  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :mocha

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

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

# Big Fat Hack (TM) Part I so the ActiveRecord connections are shared across threads.
# This is a variation of a hack you can find all over the web to make
# capybara usable without having to switch to non transactional
# fixtures.
# UPdate: this is now the exact hack shows by this website:
# http://groups.google.com/group/ruby-capybara/browse_thread/thread/248e89ae2acbf603/e5da9e9bfac733e0
#  Thread.main[:activerecord_connection] = ActiveRecord::Base.retrieve_connection
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# Regarding Poltergeist vs. Capy-Webkit: We prefer the former over the latter and strive to use it whenever possible.
# But if you really need to use Capy-Webkit you can. See '/support/acceptance/javascript.rb' for instructions on how.

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

# Uncomment these lines for debug output
#Capybara.register_driver :poltergeist do |app|
#  Capybara::Poltergeist::Driver.new(app, debug: true)
#end
Capybara.register_driver :poltergeist do |app|
 Capybara::Poltergeist::Driver.new(app, timeout: 600)
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
