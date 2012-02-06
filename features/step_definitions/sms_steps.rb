When /^I clear all sent texts$/ do
  FakeTwilio::SMS.clear_all
end

When /^the system sends "([^"]*)" to user "([^"]*)"$/ do |text, username|
  user = User.find_by_name(username)
  SMS.send_message(user, text)
end

Then /^"([^"]*)" should have received( an)? SMS "(.*)"$/m do |phone_number, _nothing, text_message|
  FakeTwilio::SMS.should have_sent_text(phone_number, text_message.gsub(/\\n/, "\n"))
end

Then /^"([^"]*)" should have received( an)? SMS '(.*)'$/ do |phone_number, _nothing, text_message|
  FakeTwilio::SMS.should have_sent_text(phone_number, text_message)
end

Then /^"([^"]*)" should have received( an)? SMS `(.*)`$/ do |phone_number, _nothing, text_message|
  FakeTwilio::SMS.should have_sent_text(phone_number, text_message)
end

Then /^"([^"]*)" should not have received( an)? SMS "(.*)"$/ do |phone_number, _nothing, text_message|
  FakeTwilio::SMS.should_not have_sent_text(phone_number, text_message)
end

Then /^"([^"]*)" should have received SMS "([^"]*)" just once$/ do |phone_number, body|
  FakeTwilio::SMS.sent_text(phone_number, body).should have(1).text
end

Then /^"([^"]*)" should have received the fallback error message SMS$/ do |phone_number|
  Then "\"#{phone_number}\" should have received the SMS 'I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text \"jsmith\").'"
end

Then /^"([^"]*)" should( not)? have received( an)? SMS including "(.*)"$/ do |phone_number, sense, _nothing, text_message|
  sense = !sense

  if sense
    FakeTwilio::SMS.should have_sent_text_including(phone_number, text_message)
  else
    FakeTwilio::SMS.should_not have_sent_text_including(phone_number, text_message)
  end
end

Then /^"([^"]*)" should( not)? have received( an)? SMS including `(.*)`$/ do |phone_number, sense, _nothing, text_message|
  sense = !sense

  if sense
    FakeTwilio::SMS.should have_sent_text_including(phone_number, text_message)
  else
    FakeTwilio::SMS.should_not have_sent_text_including(phone_number, text_message)
  end
end

Then /^"([^"]*)" should not have received any SMSes$/ do |phone_number|
  FakeTwilio::SMS.should_not have_sent_text_to(phone_number)
end

Then /^"([^"]*)" should have received the following SMS:$/ do |phone_number, sms_body|
  mo_sms(phone_number, sms_body)
end

Then /^"([^"]*)" should not have received an SMS from the default phone number$/ do |phone_number|
  FakeTwilio::SMS.should_not have_sent_text_from(TWILIO_PHONE_NUMBER, phone_number)
end

Then /^"([^"]*)" should have received an SMS from "([^"]*)"$/ do |phone_number, sending_number|
  FakeTwilio::SMS.should have_sent_text_from(sending_number, phone_number)
end

When /^"([^"]*)" sends SMS "([^"]*)"$/ do |phone_number, sms_body|
  mo_sms(phone_number, sms_body)
end

When /^"([^"]*)" sends SMS '([^']*)'$/ do |phone_number, sms_body|
  mo_sms(phone_number, sms_body)
end

When /^"([^"]*)" sends SMS "([^"]*)" to "([^"]*)"$/ do |sender_number, body, receiving_number|
  mo_sms(sender_number, body, receiving_number)
end
