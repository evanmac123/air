Given /^"(.*?)" has a claim code$/ do |username|
  User.find_by_name(username).generate_simple_claim_code!
end

Given /^"(.*?)" has the (username|SMS slug) "(.*?)"$/ do |username, _nothing, sms_slug|
  User.find_by_name(username).update_attributes(:sms_slug => sms_slug)
end

Given /^"(.*?)" has ranking query offset (\d+)$/ do |username, offset|
  User.find_by_name(username).update_attributes(:ranking_query_offset => offset.to_i)
end

Given /^"([^"]*)" has level "([^"]*)"$/ do |user_name, level_name|
  user = User.where(:name => user_name).first
  level = Level.where(:name => level_name).first
  user.levels << level
end

Given /^"([^"]*)" has notification method "([^"]*)"$/ do |username, method|
  User.find_by_name(username).update_attributes(:notification_method => method)
end

Given /^"([^"]*)" has privacy level "([^"]*)"$/ do |username, privacy_level|
  User.find_by_name(username).update_attributes(:privacy_level => privacy_level)
end

When /^an admin moves "(.*?)" to the demo "(.*?)"$/ do |username, name|
  step "I sign in as an admin via the login page"

  user = User.find_by_name(username)

  visit(edit_admin_demo_user_path(user.demo, user))

  select(name, :from => 'user[demo_id]')
  click_button "Move User"
end

Then /^"(.*?)" should be claimed by "(.*?)"$/ do |username, phone_number|
  user = User.find_by_name(username)
  user.phone_number.should == phone_number
end

Then /^"(.*?)" should not be claimed$/ do |username|
  User.find_by_name(username).phone_number.should be_blank
end

Then /^"([^"]*)" should have a null password$/ do |username|
  user = User.find_by_name(username)
  user.password.should be_nil
  user.password_confirmation.should be_nil
end

Then /^"([^"]*)" should have (height|weight|date of birth) "([^"]*)"$/ do |username, field_name, expected_value|
  user = User.find_by_name(username)
  user[field_name].to_s.should == expected_value
end

Then /^the mobile number field should be blank$/ do
  mobile_field = page.find(:css, "input#user_phone_number")
  mobile_field.value.should be_blank
end

When /^I select "([^"]*)" from the location drop\-down$/ do |input|
  page.select(input, :from => :user_location_id)
end

When /^I press the button to save the new location$/ do
  click_button("save-location")
end

Then /^"([^"]*)" should be in the "([^"]*)" game$/ do |user_name, demo_name|
  user = User.find_by_name(user_name)
  user.demo.should == Demo.find_by_name(demo_name)
end


Given /^"([^"]*)" is friends with "([^"]*)"$/ do |name_1, name_2|
  user1 = User.find_by_name(name_1)
  user2 = User.find_by_name(name_2)
  user1.befriend(user2)
  user2.accept_friendship_from(user1)
end

Given /^"([^"]*)" requests to be friends with "([^"]*)"$/ do |name_1, name_2|
  user1 = User.find_by_name(name_1)
  user2 = User.find_by_name(name_2)
  user1.befriend(user2)
end

Then /^I should (not )?see "([^"]*)" in the friends list$/ do |sense, text|
  with_scope('friends list') do
    if sense
      page.should_not have_content(text)
    else
      page.should have_content(text)
    end
  end
end

When /^the new-phone attributes for "(.*)" should( not)? be blank$/ do |name, boolean|
  user = User.find_by_name(name)
  if boolean.blank?
    user.new_phone_number.should     be_blank
    user.new_phone_validation.should be_blank
  else
    user.new_phone_number.should_not     be_blank
    user.new_phone_validation.should_not be_blank
  end
end

When /^the phone-number attribute for "(.*)" should be "(.*)"$/ do |name, phone_number|
  User.find_by_name(name).phone_number.should == phone_number
end