unless Rails.env.test?
  Twilio.configure do |config|
    config.account_sid = ENV['TWILIO_ACCOUNT_SID']
    config.auth_token  = ENV['TWILIO_AUTH_TOKEN']
  end

  $twilio_client = Twilio::REST::Client.new
end

TWILIO_MESSAGE_SERVICE_ID = ENV['TWILIO_MESSAGE_SERVICE_ID']
TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER'] || '+16176007511'
