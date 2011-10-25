def email_originated_message_received(from_email, email_subject, email_body)
  post email_path, 'from' => from_email, 'subject' => email_subject, 'to' => "email_commands@hengage.net", 'plain' => email_body
end

When /^"([^"]*)" sends EMAIL with subject "([^"]*)" and body "([^"]*)"$/ do |from_email, email_subject, email_body|
  email_originated_message_received(from_email, email_subject, email_body)
end

#Then /^"([^"]*)" should receive an email reply "([^"]*)"$/ do |email, response|
#  response = EmailCommand.find_by_response(response)
#  response.should_not be_nil
#  response.user.email.should eql email
#end

Then /^"([^"]*)" have an email command history with the phrase "([^"]*)"$/ do |email, response|
  response = EmailCommand.find_by_response(response)
  response.should_not be_nil
  response.user.email.should eql email
end

