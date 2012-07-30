require 'rubygems'
require 'spork'
require 'pry'
#uncomment the following line to use spork with the debugger
require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  #
  
  
  ############  PREVENT PRE-LOADING OF MODEL FILES  #################################
  # trap_method and trap_class_method save the method being called as a lambda which# 
  # will instead be called in the Spork.each_run block                              #
  # Because if models get preloaded here, they don't get REloaded later             #
  # # Hint: if they do get loaded, put curse words in your model file, start spork, #
  # # and follow the backtrace to see who it is that's including them               #
  #                                                                                 #
  require 'rails/application' # For some reason we need this line                   #
  require 'active_support/dependencies' # The file that has 'Loadable' in it        #
  Spork.trap_method(ActiveSupport::Dependencies::Loadable, :load)                   #
  ###################################################################################

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
    # These three were recommended in railscast #285 (Spork)
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true


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

  Rails.logger.level = 4
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
  # Bit Fat Hack(TM) Part II
  ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.




