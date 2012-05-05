source :rubygems

gem "rails", "~> 3.1.0"
gem "rack"  # Update rack to 1.3.0 or later to get rid of utf8 string regex warnings
gem "unicorn"   # Some of our capybara webkit tests fail with thin, so we use unicorn
gem 'delayed_job_active_record'
gem "high_voltage"
gem "airbrake"
gem "paperclip"
gem 'aws-sdk'
gem "will_paginate"
gem "validation_reflection"
gem "formtastic", "1.2.2"
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

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', " ~> 3.1.0"
  gem 'coffee-rails', " ~> 3.1.0"
  gem 'uglifier'
end

# RSpec needs to be in :development group to expose generators
# and rake tasks without having to type RAILS_ENV=test.
group :development, :test do
  gem "rspec-rails"
  gem "pry"
  gem "pry-doc"
  gem "pry_debug"
  gem "steak"
  gem "rails-dev-tweaks"  # The rails-dev-tweaks gem makes it so assets are not reloaded as often. 
                          # For instance, XHR requests by themselves do not reload assets when using this gem
                          # Note that all defaults can be overridden, see the github README for this gem

  platforms :mri_18 do
    gem "ruby-debug"
    gem "linecache"
  end

  platforms :mri_19 do
    gem "debugger"
    gem "linecache19"
  end

  gem "factory_girl_rails"

  gem "reek"
  gem "flay"
  gem "flog"
end

group :test do
  gem "cucumber-rails", :require => false
  gem "factory_girl_rails"
  gem "bourne"
  gem "capybara"
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
  gem "sinatra"
end
