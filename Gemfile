source :rubygems

gem "rails", "~> 3.0.3"
gem "rack"
gem "haml"
gem "high_voltage"
gem "airbrake"
gem "paperclip"
gem "will_paginate"
gem "validation_reflection"
gem "formtastic"
gem "pg"
gem "flutie"
gem "dynamic_form"
gem "twilio-rb", :git => "git://github.com/stevegraham/twilio-rb.git", :require => 'twilio'
gem "sinatra", "~> 1.0"
gem "copycopter_client", "~> 1.0.1"
gem "clearance", "~> 0.10.0"
gem "sass"
gem "aws-s3"
gem "delayed_job"

# RSpec needs to be in :development group to expose generators
# and rake tasks without having to type RAILS_ENV=test.
group :development, :test do
  gem "rspec-rails", "~> 2.4.0"

  platforms :mri_18 do
    gem "ruby-debug", "~> 0.10.4"
    gem "linecache",  "~> 0.43"
  end

  platforms :mri_19 do
    gem "ruby-debug19", "~> 0.11.6"
    gem "linecache19",  "~> 0.5.11"
  end

  gem "factory_girl_rails"

  gem "reek"
  gem "flay"
  gem "flog"
  gem "rcov"
end

group :test do
  #gem "akephalos", :git => "git://github.com/thoughtbot/akephalos.git"
  #gem 'akephalos'
  gem "cucumber-rails"
  gem "factory_girl_rails"
  gem "bourne"
  gem "capybara", "~> 0.4.1"
  gem "database_cleaner"
  gem "fakeweb"
  gem "sham_rack"
  gem "nokogiri"
  gem "timecop"
  gem "shoulda", :git => "git://github.com/thoughtbot/shoulda", :require => 'shoulda'
  gem "shoulda-matchers", :git => "git://github.com/thoughtbot/shoulda-matchers", :require => 'shoulda-matchers'
  #gem "shoulda"
  gem "email_spec", "~> 1.1"
  gem "sham_rack"
  gem "show_me_the_cookies"
  gem "capybara-webkit"
end
