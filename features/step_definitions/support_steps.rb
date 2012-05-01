Given /^support should have received a support email about "([^"]*)" with recent acts "([^"]*)"$/ do |user_specs, recent_messages|
  expected_name, expected_game, expected_email, expected_phone = user_specs.split('/')
  expected_bad_messages = recent_messages.split('/').join("\n")


  step "\"support@hengage.com\" opens the email with subject \"Help request from core app for #{expected_name} of #{expected_game}\""
  step "they should see \"Support requested by #{expected_name} of #{expected_game} (#{expected_email}, #{expected_phone})\" in the email body"
  step "they should see \"#{expected_bad_messages}\" in the email body"
end

