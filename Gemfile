source :rubygems

gem "rails", "~> 3.0.12"
gem "rack"  # Update rack to 1.3.0 or later to get rid of utf8 string regex warnings
gem "unicorn"   # Some of our capybara webkit tests fail with thin, so we use unicorn
gem "high_voltage"
gem "airbrake"
gem "paperclip"
gem 'aws-sdk'
gem "will_paginate"
gem "validation_reflection"
gem "formtastic"
gem "pg"
gem "flutie"
gem "dynamic_form"
gem "twilio-rb"
gem "clearance"
gem "sass"
gem "aws-s3"
gem "delayed_job"
gem "heroku_san"
gem "haml-rails"
gem "chronic"
gem "mixpanel"
gem "mixpanel_client"
gem "newrelic_rpm"

# RSpec needs to be in :development group to expose generators
# and rake tasks without having to type RAILS_ENV=test.
group :development, :test do
  gem "rspec-rails"
  gem "pry"
  gem "pry-doc"
  gem "pry_debug"
  gem "steak"

  platforms :mri_18 do
    gem "ruby-debug", "~> 0.10.4"
    gem "linecache",  "~> 0.43"
  end

  platforms :mri_19 do
    gem "debugger"
    gem "linecache19",  "~> 0.5.11"
  end

  gem "factory_girl_rails"

  gem "reek"
  gem "flay"
  gem "flog"
  gem "parallel_tests"
end

group :test do
  gem "cucumber-rails", :require => false
  gem "factory_girl_rails"
  gem "bourne"
  gem "capybara", "~> 1.0.0"
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
  gem "capybara-webkit", ">= 0.6.1"
  gem "sinatra", "~> 1.0"
end
