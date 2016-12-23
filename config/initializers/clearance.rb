Clearance.configure do |config|
  config.mailer_sender = 'Airbo <donotreply@airbo.com>'
  config.password_strategy = Clearance::PasswordStrategies::SHA1

  config.cookie_expiration = lambda do |cookies|
    if cookies[:remember_me]
      10.years.from_now.utc
    else
      20.minutes.from_now.utc
    end
  end
end
