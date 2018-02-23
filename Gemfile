source "https://www.rubygems.org"

ruby "2.3.5"

gem "rails", "=4.2.10"
gem "unicorn", "~> 5.3.1"
gem "pg", "~> 0.18.0"
gem "rack-cors", require: "rack/cors"
gem "rack-timeout", require: false
gem "jbuilder", "~> 2.7.0"
gem "mongoid", "~> 4.0"
gem "bson", "~> 2.2"
gem "redis", "~> 3.3.3"
gem "redis-rails", "~> 5.0.2"
gem "ar_redis"
gem "webpacker", "~> 3.0"

# TODO: update to gem "aws-sdk-s3", "~> 1" when paperclip releases support for aws-sdk 3: https://github.com/thoughtbot/paperclip/pull/2481
gem 'aws-sdk', '< 3.0'
gem "paperclip", "~> 5.2.0"
gem "delayed_paperclip", "~> 3.0.0"

gem "twilio-ruby", "~> 5.2.3"
gem "high_voltage", "~> 3.0.0"
gem "flutie", "~> 2.0"
gem "clearance", "~> 1.16.0"
### Remove after porting passwords to BCRYPT:
gem "clearance-deprecated_password_strategies", "~> 1.10.0"
###
gem "delayed_job", "~> 4.1.0"
gem "delayed_job_active_record", "~> 4.1.2"
gem "activerecord-collection_cache_key", "~> 0.1.3"

gem "stripe", "~> 3.9.0"
gem "font-awesome-rails", ">= 4.7"
gem "kaminari", "~> 1.1.1"
gem "browser", "~> 2.5.0"
gem "counter_culture", "~> 1.9.0"
gem "sanitize", "~> 4.5.0"
gem "htmlentities", "~> 4.3.3"
gem "simple_enum", "~> 1.6.9"
gem "descriptive_statistics", "~> 2.5.1", require: "descriptive_statistics/safe"
gem "mobvious-rails", "~> 0.1.2"
gem "groupdate", "~> 3.2.0"
gem "searchkick", "~> 2.4.0"
gem "searchjoy", "~> 0.3.1"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false


# Redis
gem "nest", "~> 2.0"

### Spreadsheet creation
# TODO: Update to a more maintained gem.
gem "axlsx", git: "https://github.com/theairbo/axlsx.git"
###

### Integrations
gem "delighted", "~> 1.7.0"
gem "airbrake", "~> 5.4"
gem "scout_apm", "~> 2.4"
gem "chartmogul-ruby", "~> 1.1.4", require: "chartmogul"
# NOTE: Our hack to prevent too users from making it to Intercom unless they click the messenger gets harder after intercom-rails 0.3.4: https://github.com/intercom/intercom-rails/commit/b1c730bc6dcb3c9b4655c364d168288eed1dbef5
gem "intercom-rails", "0.3.4"
gem "intercom", "~> 3.5.23"
gem "mixpanel_client", "~> 4.1.6"
###

### Move to Yarn
gem "jquery-rails", "~> 4.3.1"
gem "jquery-validation-rails", "~> 1.16.0"
gem "jquery-fileupload-rails", "~> 0.4.5"
###

### DO NOT USE. We are just maintaining compatibility with current features until with remove the dependency (just tile stats modal). No support for Rails 5
gem "wice_grid", git: "https://github.com/theairbo/wice_grid", branch: "rails_4_2_10"
###

### Plan to Remove
gem "acts-as-taggable-on", "~> 3.5.0"
gem "rolify", "~> 5.1.0"
gem "addressable", "~> 2.5.2"
gem "acts_as_singleton", "~> 0.0.8"
gem "mixpanel", "~> 4.1.1" # Migrate to official gem
gem "chronic", "~> 0.10.2"
gem "haml-rails", "~> 1.0.0"
gem "nokogiri", "~> 1.8.1"
gem "carrierwave_direct", "~> 0.0.15"
gem "aws-sdk-v1", "~> 1.59.0" # V1 used for bulk upload and Tile attachments (migrate to v3 in rewrites)
###

gem "sass-rails", "~> 4.0.0"
gem "coffee-rails", "~> 4.0.0"
gem "uglifier", ">= 1.3.0"
gem "handlebars_assets", "~> 0.22.0"

group :development, :test do
  gem "colored"
  gem "rspec-rails", "~> 3.0"
  gem "factory_bot_rails"
  gem "steak"
  gem "pry-rails"
	gem "pry-byebug"
  gem "awesome_print"
end

group :test do
  gem "simplecov"
  gem "codeclimate-test-reporter", "~> 1.0.0"
  gem "bourne"
  gem "test_after_commit"
  gem "capybara"
  gem "database_cleaner"
  gem "sham_rack"
  gem "timecop"
  gem "shoulda-matchers", require: false
  gem "email_spec"
  gem "sinatra"
  gem "mocha"
  gem "selenium-webdriver"
  gem "capybara-selenium"
end

group :development do
  gem "thin"
  gem "foreman"
  gem "quiet_assets"
  gem "letter_opener"
  gem "better_errors"
  gem "binding_of_caller"
  gem "web-console", "~> 2.0"
  gem "spring"
  gem "rubocop", require: false
  gem "reek", "~> 4.7.3", require: false
end

group :production do
  gem "rails_12factor"
end
