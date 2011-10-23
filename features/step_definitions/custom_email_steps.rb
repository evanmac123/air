Then /^I should not see "([^"]*)" in the email body$/ do |text|
  current_email.default_part_body.to_s.should_not =~ Regexp.new(text)
end
