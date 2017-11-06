source 'https://www.rubygems.org'

ruby '2.1.8'

gem 'rails', '=3.2.22.1'
gem 'rack', '~> 1.4.7'
gem 'rack-cors', :require => 'rack/cors'
gem 'delayed_job_active_record'
gem 'high_voltage'
gem 'paperclip', '~>3.3.0'
gem 'paperclip-meta'
gem 'aws-sdk'
gem 'formtastic'
gem 'pg'
gem 'flutie'
gem 'twilio-ruby', '~> 5.2.3'
gem 'clearance'
### Remove after porting passwords to BCRYPT:
gem 'clearance-deprecated_password_strategies'
###
gem 'delayed_job'
gem 'haml-rails'
gem 'chronic'
gem 'mixpanel'
gem 'mixpanel_client'
gem 'mongoid'
gem 'bson_ext'
gem 'pundit'
gem 'google_drive'
gem 'cache_digests'
gem 'activerecord-collection_cache_key'
gem 'groupdate'

gem 'jquery-rails'
gem 'jquery-validation-rails'
gem 'historyjs-rails'

gem 'nokogiri'
gem 'json', '>= 1.7.7'
gem 'carrierwave_direct'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'rack-timeout', require: false
gem 'delayed_paperclip'
gem 'mobvious-rails'
gem 'rails3_before_render'
gem 'rollout'
gem 'font-awesome-rails', '>= 4.7'
gem 'wice_grid', git: 'https://github.com/theairbo/wice_grid', branch: 'rails3'
gem 'kaminari'
gem 'browser'
gem 'squeel'
gem 'draper', '~> 1.3'
gem 'strong_parameters'
gem 'intercom-rails'
gem 'intercom','~>2.4.2'
gem 'counter_culture'
gem 'css_splitter', :git => 'https://github.com/theairbo/css_splitter.git' #Allow customization of MAX_SELECTORS_DEFAULT via environment variable
gem 'sanitize'
gem 'htmlentities'
gem 'unicorn'   # Some of our capybara webkit tests fail with thin, so we use unicorn
gem 'jquery-fileupload-rails'#
gem 'acts_as_singleton'
gem 'acts-as-taggable-on', '~> 3.5.0'
#redis + caching
gem 'redis'
gem 'redis-rails'
gem 'nest'

gem 'lograge'

gem 'roo'
gem 'roo-xls'

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

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'jquery-ui-rails'
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
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'fakeweb'
  gem 'sham_rack'
  gem 'timecop'
  gem 'shoulda-matchers', require: false
  gem 'email_spec'
  gem 'capybara-webkit'
  gem 'poltergeist'
  gem 'sinatra'
  gem 'mocha'
  gem 'selenium-webdriver', '~> 2.53.4'
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
