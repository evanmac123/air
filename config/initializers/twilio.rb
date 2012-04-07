Twilio::Config.setup \
  :account_sid => ENV['TWILIO_ACCOUNT_SID'],
  :auth_token => ENV['TWILIO_AUTH_TOKEN']


TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER'] || "+11234567890"
