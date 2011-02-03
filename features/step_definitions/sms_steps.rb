Then /^"([^"]*)" should have received an SMS "([^"]*)"$/ do |phone_number, text_message|
  FakeTwilio::SMS.should have_sent_text(phone_number, text_message)
end

When /^"([^"]*)" sends SMS "([^"]*)"$/ do |phone_number, sms_body|
  post sms_path, 'From' => phone_number, 'To' => FAKE_TWILIO_ACCOUNT_SID, 'Body' => sms_body
end
