Then /^"([^"]*)" should have received an SMS "([^"]*)"$/ do |phone_number, text_message|
  FakeTwilio::SMS.should have_sent_text(phone_number, text_message)
end

When /^"([^"]*)" sends SMS "([^"]*)"$/ do |phone_number, sms_body|
  pending
end
