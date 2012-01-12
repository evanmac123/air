Then /^I should not see "([^"]*)" in the email body$/ do |text|
  current_email.default_part_body.to_s.should_not =~ Regexp.new(text)
end

Then /^I should see the password reset full URL for "([^"]*)" in the email body$/ do |username|
  user = User.find_by_name(username)
  Then %{I should see 'href="#{edit_user_password_url(user, :token => user.confirmation_token)}"' in the email body}
end

Then /^I should see the profile page full URL for "([^"]*)" in the email body$/ do |username|
  user = User.find_by_name(username)
  Then %{I should see 'href="#{user_url(user)}"' in the email body}
end

Then /^I should see '(.*?)' in the email body$/ do |text|
  current_email.default_part_body.to_s.should include(text)
end

Then /^I should see the following in the email body:$/ do |string|
  current_email.default_part_body.to_s.should include(string)
end

