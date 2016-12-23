source 'https://www.rubygems.org'

ruby '2.0.0'

gem 'rails', '=3.2.22.1'
gem 'rack' # Update rack to 1.3.0 or later to get rid of utf8 string regex warnings
gem 'delayed_job_active_record'
gem 'high_voltage'
gem 'paperclip', '~>3.3.0'
gem 'paperclip-meta'
gem 'aws-sdk'
gem 'formtastic'
gem 'pg'
gem 'flutie'
gem 'twilio-rb'
gem 'clearance', '~> 0.16.3'
gem 'aws-s3'
gem 'delayed_job'
gem 'haml-rails'
gem 'chronic'
gem 'mixpanel'
gem 'mixpanel_client'
gem 'mongoid'
gem 'bson_ext'
gem 'pundit'
gem 'google_drive'
gem 'time_difference'
gem 'cache_digests'
gem 'activerecord-collection_cache_key'

gem 'jquery-rails'
gem 'jquery-validation-rails'
gem 'historyjs-rails'

gem 'nokogiri'
gem 'lazy_high_charts'#, '~>1.4.0'
gem 'json', '>= 1.7.7'
gem 'carrierwave_direct'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'rack-timeout'
gem 'delayed_paperclip'
gem 'mobvious-rails'
gem 'rails3_before_render'
gem 'rollout'
gem 'font-awesome-rails'
gem 'wice_grid', git: 'https://github.com/avbrychak/wice_grid', branch: 'rails3'
gem 'kaminari'
gem 'browser'
gem 'squeel'
gem 'draper', '~> 1.3'
gem 'strong_parameters'
gem 'intercom', '~>2.4.2'
gem 'counter_culture'
gem 'css_splitter', :git => 'https://github.com/theairbo/css_splitter.git' #Allow customization of MAX_SELECTORS_DEFAULT via environment variable
gem 'sanitize'
gem 'htmlentities'
gem 'rack-mini-profiler', require: false
gem 'unicorn'   # Some of our capybara webkit tests fail with thin, so we use unicorn
gem 'newrelic_rpm'
gem 'jquery-fileupload-rails'#
gem 'acts_as_singleton'
gem 'acts-as-taggable-on', '~> 3.5.0'
#redis + caching
gem 'redis'
gem 'redis-rails'
gem 'nest'

gem 'roo'
gem 'roo-xls'
gem 'addressable'
gem 'humanize_boolean'

gem 'delighted'
gem 'skylight'
gem 'airbrake', '~> 5.4'
#
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'asset_sync'
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'jquery-ui-rails'
end


group :development, :test do
  gem 'faker'
  gem 'colored'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'steak'
	gem 'rspec-mocks'
  gem 'pry-rails'
	gem 'pry-byebug'
end

group :test do
  gem 'simplecov'
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'cucumber-rails', require: false
  gem 'bourne'
  gem 'test_after_commit'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'fakeweb'
  gem 'sham_rack'
  gem 'timecop'
  gem 'shoulda'
  gem 'shoulda-matchers'
  gem 'email_spec', '~> 1.1'
  gem 'capybara-webkit'
  gem 'poltergeist'
  gem 'sinatra'
  gem 'mocha', require: false
  gem 'selenium-webdriver'
end

group :development do
  gem 'thin'
  gem 'quiet_assets'
  gem 'letter_opener'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :production do
  gem 'rails_12factor'
end
