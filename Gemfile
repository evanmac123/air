source 'https://www.rubygems.org'

ruby '2.1.8'

gem 'rails', '=3.2.22.1'
gem 'rack', '~> 1.4.5'
gem 'unicorn', '~> 5.3.1'
gem 'pg', '~> 0.18'
gem 'rack-cors', require: 'rack/cors'

gem 'aws-sdk'
gem 'paperclip', '~> 4.3'
gem 'delayed_paperclip', '~> 2.9.0'
gem 'high_voltage', '~> 3.0.0'
gem 'flutie'
gem 'twilio-ruby', '~> 5.2.3'
gem 'clearance'
### Remove after porting passwords to BCRYPT:
gem 'clearance-deprecated_password_strategies'
###
gem 'delayed_job', '~> 4.1.0'
gem 'delayed_job_active_record'
gem 'haml-rails'
gem 'chronic'
gem 'mixpanel'
gem 'mixpanel_client'
gem 'mongoid'
gem 'bson_ext'
gem 'cache_digests'
gem 'activerecord-collection_cache_key'
gem 'groupdate'

gem 'nokogiri'
gem 'json', '>= 1.7.7'
gem 'carrierwave_direct'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'rack-timeout', require: false
gem 'mobvious-rails'
gem 'font-awesome-rails', '>= 4.7'
gem 'kaminari'
gem 'browser'
gem 'intercom-rails'
gem 'intercom','~>2.4.2'
gem 'counter_culture'
gem 'sanitize'
gem 'htmlentities'
gem 'acts_as_singleton'
gem 'acts-as-taggable-on', '~> 3.5.0'

#redis + caching
gem 'redis'
gem 'redis-rails'
gem 'nest', '~> 2.0'

# Complex spreadsheet creation
gem 'rubyzip', '~> 1.1.0'
gem 'axlsx', '2.1.0.pre'
#

gem 'addressable'
gem 'humanize_boolean'

gem 'delighted'
gem 'airbrake', '~> 5.4'

gem 'scout_apm', '~> 2.3'

gem 'searchkick'
gem 'searchjoy'
gem 'rolify'
gem 'simple_enum', '~> 1.6.9'
gem 'chartmogul-ruby', require: 'chartmogul'
gem 'descriptive_statistics', require: 'descriptive_statistics/safe'
gem 'jbuilder'

# Move to Yarn
gem 'jquery-rails'
gem 'jquery-validation-rails'
gem 'jquery-fileupload-rails'
#

# Plan to Remove
gem 'wice_grid', git: 'https://github.com/theairbo/wice_grid', branch: 'rails3'
gem 'rails3_before_render'
gem 'draper', '~> 1.3'
gem 'strong_parameters'
gem 'squeel'
#

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'handlebars_assets', '~>0.22.0'
end

group :development, :test do
  gem 'faker'
  gem 'colored'
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
  gem 'steak'
  gem 'pry-rails'
	gem 'pry-byebug'
  gem 'awesome_print'
end

group :test do
  gem 'simplecov'
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'bourne'
  gem 'test_after_commit'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'sham_rack'
  gem 'timecop'
  gem 'shoulda-matchers', require: false
  gem 'email_spec'
  gem 'sinatra'
  gem 'mocha'
  gem 'selenium-webdriver'
  gem 'capybara-selenium'
end

group :development do
  gem 'thin'
  gem 'foreman'
  gem 'quiet_assets'
  gem 'letter_opener'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :production do
  gem 'rails_12factor'
end
