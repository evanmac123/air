Clearance.configure do |config|
  config.mailer_sender = 'H Engage <donotreply@hengage.com>'
  # this sets the default time until logged out (if you DON'T check /remember me/)
  config.cookie_expiration = lambda {5.minutes.from_now.utc}
end
