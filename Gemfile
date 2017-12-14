source 'https://www.rubygems.org'

ruby '2.1.8'

gem 'rails', '4.0.0'
gem 'unicorn', '~> 5.3.1'
gem 'pg', '~> 0.18'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-timeout', require: false
gem 'jbuilder', '~> 2.6.4'
gem 'mongoid', '~> 3.0'
gem 'bson_ext', '~> 1.12'

gem 'aws-sdk-s3', '~> 1'
gem 'paperclip', '~> 4.3'
gem 'delayed_paperclip', '~> 2.9.0'

gem 'twilio-ruby', '~> 5.2.3'
gem 'high_voltage', '~> 3.0.0'
gem 'flutie', '~> 2.0'
gem 'clearance', '~> 1.16.0'
### Remove after porting passwords to BCRYPT:
gem 'clearance-deprecated_password_strategies', '~> 1.10.0'
###
gem 'delayed_job', '~> 4.1.0'
gem 'delayed_job_active_record', '~> 4.1.2'
gem 'activerecord-collection_cache_key', '~> 0.1.3'

gem 'json', '>= 1.7.7'
gem 'stripe', '~> 3.9.0'
gem 'font-awesome-rails', '>= 4.7'
gem 'kaminari', '~> 0.16'
gem 'browser', '~> 2.5.0'
gem 'counter_culture', '~> 1.9.0'
gem 'sanitize', '~> 4.5.0'
gem 'htmlentities', '~> 4.3.3'
gem 'acts-as-taggable-on', '~> 3.5.0'
gem 'simple_enum', '~> 1.6.9'
gem 'descriptive_statistics', '~> 2.5.1', require: 'descriptive_statistics/safe'
gem 'mobvious-rails', '~> 0.1.2'

# Upgrade for Rails 4.2
gem 'searchkick', '~> 1.5.1'
gem 'searchjoy', '~> 0.1.0'
gem 'groupdate', '~> 3.2.0'
gem 'redis', '~> 3.3.3'
gem 'redis-rails', '~> 3.2.4'
gem 'jquery-rails', '~> 3.1.4'

# Redis
gem 'nest', '~> 2.0'

### Complex spreadsheet creation
gem 'rubyzip', '~> 1.1.0'
gem 'axlsx', '2.1.0.pre'
###

### Integrations
gem 'delighted', '~> 1.7.0'
gem 'airbrake', '~> 5.4'
gem 'scout_apm', '~> 2.3'
gem 'chartmogul-ruby', '~> 1.1.4', require: 'chartmogul'
gem 'intercom', '~> 2.4.3'
gem 'intercom-rails', '~> 0.3.4'
gem 'mixpanel_client', '~> 4.1.6'
###

### Move to Yarn
gem 'jquery-validation-rails', '~> 1.16.0'
gem 'jquery-fileupload-rails', '~> 0.4.5'
###

### No support for Rails 4
gem 'strong_parameters' # built-in
gem 'cache_digests', '~> 0.3.1'
gem 'rails3_before_render'
###

### No support for Rails 5
gem 'squeel', '~> 1.2.2'
gem 'wice_grid', git: 'https://github.com/theairbo/wice_grid', branch: 'rails3'
###

### Plan to Remove
gem 'rolify', '~> 5.1.0'
gem 'addressable', '~> 2.5.2'
gem 'acts_as_singleton', '~> 0.0.8'
gem 'mixpanel', '~> 4.1.1' # Migrate to official gem
gem 'chronic', '~> 0.10.2'
gem 'haml-rails', '~> 0.4'
gem 'nokogiri', '~> 1.8.1'
gem 'carrierwave_direct', '~> 0.0.15'
gem 'draper', '~> 1.3'
gem 'aws-sdk-v1', '~> 1.59.0' # V1 used for bulk upload and Tile attachments (migrate to v3 in rewrites)
###

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
