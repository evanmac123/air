Clearance.configure do |config|
  config.mailer_sender = 'Airbo <donotreply@airbo.com>'
  # this sets the default time until logged out (if you DON'T check /remember me/)
  config.cookie_expiration = lambda {20.minutes.from_now.utc}
end
