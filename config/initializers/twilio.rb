Twilio::Config.setup do
  account_sid ENV['TWILIO_ACCOUNT_SID'] || FAKE_TWILIO_ACCOUNT_SID
  auth_token  ENV['TWILIO_AUTH_TOKEN']  || FAKE_TWILIO_AUTH_TOKEN
end
