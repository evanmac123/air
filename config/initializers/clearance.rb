Clearance.configure do |config|
  config.mailer_sender = 'H Engage <donotreply@hengage.com>'
  config.cookie_expiration = lambda {5.minutes.from_now.utc}
end
