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
gem 'fancybox-rails', :git => "https://github.com/hecticjeff/fancybox-rails.git"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'asset_sync'
  gem 'sass-rails', "3.1.4" #Locking sass-rails at 3.1.4 so that assets will precompile
  gem 'coffee-rails', " ~> 3.1.0"
  gem 'uglifier'
  gem 'jquery-ui-rails'
end

# RSpec needs to be in :development group to expose generators
# and rake tasks without having to type RAILS_ENV=test.
group :development, :test do
  gem "colored"
  gem "rspec-rails"
  gem "pry-debugger"
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

  # TL;DR We don't use cover_me, but don't take it out.
  #
  #
  # Full explanation:
  # We're not using cover_me, but removing it makes deserialization of 
  # Characteristics fail when it tries to deserialize the datatype.
  #
  # Apparently if Foo is a class, and you do YAML.load(YAML.dump(Foo)), you
  # get a String back, not a Class. But not if you require cover_me.
  #
  # This is so fucking retarded...but I haven't been able to track down why it
  # is that cover_me makes the difference.
  gem "cover_me"
  gem "getopt"
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
  gem 'spork', '~> 1.0rc' 
end

group :development do 
  gem 'guard-rspec'
  #gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i # guard-rspec depends on this, but only OSX operating systems don't have it already
  gem 'guard-spork'
  gem 'guard-livereload'
end
