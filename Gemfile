source :rubygems

ruby '1.9.3'

gem "rails", "~> 3.2.0"
gem "rack"  # Update rack to 1.3.0 or later to get rid of utf8 string regex warnings
gem "unicorn"   # Some of our capybara webkit tests fail with thin, so we use unicorn
gem 'delayed_job_active_record'
gem "high_voltage"
gem "airbrake"
gem "paperclip"
gem "paperclip-meta"
gem 'aws-sdk'
gem "will_paginate"
gem "formtastic"
gem "pg"
gem "flutie"
gem "dynamic_form"
gem "twilio-rb"
gem "clearance"
gem "aws-s3"
gem "delayed_job"
gem "heroku_san"
gem "haml-rails"
gem "chronic"
gem "mixpanel"
gem "mixpanel_client"
gem "newrelic_rpm"
gem "mongoid"
gem "bson_ext"
gem 'jquery-rails'
gem 'fancybox-rails', :git => "https://github.com/hecticjeff/fancybox-rails.git"
gem 'nokogiri'

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
  gem "colored"
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "steak"
  gem "rails-dev-tweaks"  # The rails-dev-tweaks gem makes it so assets are not reloaded as often. 
                          # For instance, XHR requests by themselves do not reload assets when using this gem
                          # Note that all defaults can be overridden, see the github README for this gem

  gem "getopt"
  #gem "ruby-debug19", :require => 'ruby-debug'
  gem 'debugger'
end

group :test do
  gem "cucumber-rails", :require => false
  gem "factory_girl_rails"
  gem "bourne"
  gem "capybara"
  gem 'capybara-screenshot'
  gem "database_cleaner"
  gem "fakeweb"
  gem "sham_rack"
  gem "nokogiri"
  gem "timecop"
  gem "shoulda"
  gem "shoulda-matchers"
  gem "email_spec", "~> 1.1"
  gem "sham_rack"
  gem "show_me_the_cookies"
  gem "capybara-webkit"
  gem "poltergeist"
  gem "sinatra"
end

group :development do 
  gem 'letter_opener'
end
