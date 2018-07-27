unless Rails.env.test?
  Twilio.configure do |config|
    config.account_sid = ENV['TWILIO_ACCOUNT_SID']
    config.auth_token  = ENV['TWILIO_AUTH_TOKEN']
  end

  $twilio_client = Twilio::REST::Client.new
end

TWILIO_MESSAGE_SERVICE_ID = ENV['TWILIO_MESSAGE_SERVICE_ID']
TWILIO_SHORT_CODE_SID = ENV['TWILIO_SHORT_CODE_SID']
TWILIO_SHORT_CODE = ENV['TWILIO_SHORT_CODE'] || $twilio_client.short_codes(ENV['TWILIO_SHORT_CODE_SID']).fetch.friendly_name
