def mobile_originated_message_received(phone_number, sms_body)
  post sms_path, 'From' => phone_number, 'To' => FAKE_TWILIO_ACCOUNT_SID, 'Body' => sms_body

  # When Twilio posts a message to us, if the response is plaintext, it sends
  # a reply with that text back to the original sender. We want to capture
  # those messages too, so we pretend like we posted them explicitly.

  if response.content_type == 'text/plain'
    FakeTwilio::SMS.post('To' => phone_number, 'Body' => response.body)
  end
end

Then /^"([^"]*)" should have received an SMS "(.*)"$/ do |phone_number, text_message|
  FakeTwilio::SMS.should have_sent_text(phone_number, text_message)
end

Then /^"([^"]*)" should have received an SMS '(.*)'$/ do |phone_number, text_message|
  FakeTwilio::SMS.should have_sent_text(phone_number, text_message)
end

Then /^"([^"]*)" should not have received an SMS "(.*)"$/ do |phone_number, text_message|
  FakeTwilio::SMS.should_not have_sent_text(phone_number, text_message)
end

Then /^"([^"]*)" should have received the fallback error message SMS$/ do |phone_number|
  Then "\"#{phone_number}\" should have received the SMS 'I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text \"jsmith\").'"
end

Then /^"([^"]*)" should have received an SMS including "(.*)"$/ do |phone_number, text_message|
  FakeTwilio::SMS.should have_sent_text_including(phone_number, text_message)
end


When /^"([^"]*)" sends SMS "([^"]*)"$/ do |phone_number, sms_body|
  mobile_originated_message_received(phone_number, sms_body)
end

When /^"([^"]*)" sends SMS '([^']*)'$/ do |phone_number, sms_body|
  mobile_originated_message_received(phone_number, sms_body)
end
