Given /^"(.*?)" has( the)? password "(.*?)"$/ do |username, _nothing, new_password|
  user = User.find_by_name(username)
  user.password = user.password_confirmation = new_password
  user.save!
end

When /^I fill in the login fields (as|with) "(.*?)"$/ do |_nothing, login_string|
  username, password = login_string.split('/')
  user = User.find_by_name(username)
  step %{I fill in the email field with "#{user.email}"}
  step %{I fill in the password field with "#{password}"}
end

When /^I sign in via the login page (as|with) "(.*?)"( and choose to be remembered)?$/ do |_nothing, login_string, remember|
  visit new_session_path
  step %{I fill in the login fields as "#{login_string}"}
  if remember
    step %{I check the remember-me checkbox}
  end

  click_button "Log In"
end

When /^I sign in( as an admin)? via the login page( as an admin)?$/ do |is_admin_1, is_admin_2|
  is_admin = is_admin_1 || is_admin_2
  factory_type = is_admin ? :site_admin : :user
  user = FactoryGirl.create factory_type, :password => 'foobar', :password_confirmation => 'foobar'
  step "I sign in via the login page as \"#{user.name}/foobar\""
end

When /^I am not logged in$/ do
  delete sign_out_path
end

When /^I fill in the email field with "([^"]*)"$/ do |text|
  fill_in 'session[email]', :with => text
end

When /^I fill in the password field with "([^"]*)"$/ do |text|
  fill_in 'session[password]', :with => text
end

When /^I check the remember\-me checkbox$/ do
  check "session[remember_me]"
end

Then /^I should( not)? see the session expiration message$/ do |sense|
  Then %{I should#{sense} see "Your session has expired. Please log back in to continue."}
end
