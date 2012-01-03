Given /^"(.*?)" has a claim code$/ do |username|
  User.find_by_name(username).generate_simple_claim_code!
end

Given /^"(.*?)" has the (unique ID|SMS slug) "(.*?)"$/ do |username, _nothing, sms_slug|
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

When /^an admin moves "(.*?)" to the demo "(.*?)"$/ do |username, company_name|
  When "I sign in as an admin via the login page"

  user = User.find_by_name(username)

  visit(edit_admin_demo_user_path(user.demo, user))

  select(company_name, :from => 'user[demo_id]')
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

Then /^the mobile number field should be blank$/ do
  mobile_field = page.find(:css, "input#user_phone_number")
  mobile_field.value.should be_blank
end

