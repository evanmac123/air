source :rubygems

gem "rails", "~> 3.0.3"
gem "rack"
gem "haml"
gem "high_voltage"
gem "hoptoad_notifier"
gem "paperclip"
gem "will_paginate"
gem "validation_reflection"
gem "formtastic"
gem "pg"
gem "flutie"
gem "dynamic_form"
gem "twilio-rb", :git => "git://github.com/stevegraham/twilio-rb.git", :require => 'twilio'
gem "sinatra", "~> 1.0"
gem "copycopter_client", "~> 1.0.0.beta6"
gem "clearance", "~> 0.10.0"
gem "sass"

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
end

group :test do
  gem "akephalos", :git => "git://github.com/thoughtbot/akephalos.git"
  gem "cucumber-rails"
  gem "factory_girl_rails"
  gem "bourne"
  gem "capybara"
  gem "database_cleaner"
  gem "fakeweb"
  gem "sham_rack"
  gem "nokogiri"
  gem "timecop"
  gem "shoulda"
  gem "email_spec", "~> 1.1"
  gem "sham_rack"
  gem "show_me_the_cookies"
end
