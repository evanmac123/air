Twilio::Config.setup do
  account_sid ENV['TWILIO_ACCOUNT_SID']
  auth_token  ENV['TWILIO_AUTH_TOKEN']
end

TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER']
