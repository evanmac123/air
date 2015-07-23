source "https://www.rubygems.org"

ruby '2.0.0'

gem "rails", "=3.2.21"
gem "rack"  # Update rack to 1.3.0 or later to get rid of utf8 string regex warnings
gem 'delayed_job_active_record'
gem "high_voltage"
gem "airbrake"
gem "paperclip", "~>3.3.0"
gem "paperclip-meta"
gem 'aws-sdk'
gem "formtastic"
gem "pg"
gem "flutie"
gem "twilio-rb"
gem "clearance"
gem "aws-s3"
gem "delayed_job"
gem "haml-rails"
gem "chronic"
gem "mixpanel"
gem "mixpanel_client"
gem "mongoid"
gem "bson_ext"
gem "pundit"

gem 'jquery-rails'
gem 'jquery-validation-rails'
gem "historyjs-rails"

gem 'nokogiri'
gem 'lazy_high_charts', '~>1.4.0'
gem 'json', ">= 1.7.7"
gem 'carrierwave_direct'
gem 'redis'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'rack-timeout'
gem 'delayed_paperclip'
gem 'mobvious-rails'
gem 'rails3_before_render'
gem 'rollout'
gem 'font-awesome-rails'
gem 'wice_grid'
gem 'kaminari'
gem 'browser'
gem "squeel"
gem 'draper', '~> 1.3'
gem 'introjs-rails'
gem 'redis-rails'
gem 'strong_parameters'
gem 'intercom'
gem 'counter_culture'
gem 'require_all'
gem 'css_splitter'
gem 'sanitize'
gem 'htmlentities'
gem 'rack-mini-profiler', require: false
gem 'flamegraph'
gem "unicorn"   # Some of our capybara webkit tests fail with thin, so we use unicorn
gem "newrelic_rpm"
gem "jquery-fileupload-rails"#
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'asset_sync'
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'jquery-ui-rails'
end

# A Note About Debuggers:
# -----------------------
# Used to load the 'debugger' and 'pry-debugger' gems, but then a (wimped-out) employee decided to
# develop using an IDE instead of the command line and encountered a conflict with those gems and
# his 'ruby-debug-ide' gem, i.e. his debugger would not work if the other debugger gems were included
# in the mix.
# Conditional inclusion in this 'Gemfile' screwed up 'gemfile.lock' => not a solution.
# So all references to debugger-related gems have been removed => each developer is responsible
# for loading whatever debugger gems s/he needs.
# The code contains several references to the original gems, which will screw up those who do not have
# them loaded. The solution to this problem is for those people to define an environment variable called
# 'NO_DEBUGGER' so the problem statements can be suffixed with an " unless ENV['NO_DEBUGGER'] " qualifier.
# If you need to go this route, make sure you define 'NO_DEBUGGER' at the system level and not the user one.
# For example, in Ubuntu this means adding the line "NO_DEBUGGER=true" in '/etc/environment' instead of
# the line "export NO_DEBUGGER=true" in '~/.bashrc'

# RSpec needs to be in :development group to expose generators
# and rake tasks without having to type RAILS_ENV=test.
group :development, :test do
	gem "thin"
  gem "colored"
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "steak"
	gem "rspec-mocks"
  gem "rails-dev-tweaks"  # The rails-dev-tweaks gem makes it so assets are not reloaded as often.
                          # For instance, XHR requests by themselves do not reload assets when using this gem
                          # Note that all defaults can be overridden, see the github README for this gem

  gem "getopt"
  #gem "ruby-debug19", :require => 'ruby-debug'
  # gem 'debugger'
	gem 'pry'
	gem 'pry-byebug'
end

group :test do
  gem "cucumber-rails", :require => false
  gem "bourne"
  gem "capybara"
  gem 'capybara-screenshot'
  gem "database_cleaner"
  gem "fakeweb"
  gem "sham_rack"
  gem "timecop"
  gem "shoulda"
  gem "shoulda-matchers"
  gem "email_spec", "~> 1.1"
  gem "capybara-webkit"
  gem "poltergeist"
  gem "sinatra"
  gem "mocha"
  gem "selenium-webdriver"
  gem 'test_after_commit'
end

group :development do
  gem 'quiet_assets'
  gem 'letter_opener'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem "rails-erd"
  gem 'meta_request'
end

group :production do
  gem 'rails_12factor'
end
