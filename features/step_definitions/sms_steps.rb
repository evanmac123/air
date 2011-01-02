Then /^"([^"]*)" should have received an SMS "([^"]*)"$/ do |phone_number, text_message|
  FakeTwilio::SMS.should have_text(phone_number, text_message)
end
