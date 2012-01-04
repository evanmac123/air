Then /^"([^"]*)" should receive an SMS containing their new phone validation code$/ do |username|
  user = User.where(:name => username).first
  token = user.new_phone_validation
  new_phone_number = user.new_phone_number
  Then "\"#{new_phone_number}\" should have received an SMS including \"#{token}\""
end

When /^"([^"]*)" fills in the new phone validation field with their validation code$/ do |username|
  user = User.where(:name => username).first
  token = user.new_phone_validation
  fill_in('user_new_phone_validation', :with => token )
end

When /^"([^"]*)" fills in the new phone validation field with the wrong validation code$/ do |username|
  fill_in('user_new_phone_validation', :with => "23456" )
end

When /^I press the button to verify the new phone number$/ do
  find('#save-phone-validation').click
end
