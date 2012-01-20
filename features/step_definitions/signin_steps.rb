Given /^"(.*?)" has( the)? password "(.*?)"$/ do |username, _nothing, new_password|
  user = User.find_by_name(username)
  user.password = user.password_confirmation = new_password
  user.save!
end

When /^I fill in the login fields (as|with) "(.*?)"$/ do |_nothing, login_string|
  username, password = login_string.split('/')
  user = User.find_by_name(username)
  fill_in 'session[email]', :with => user.email
  fill_in 'session[password]', :with => password
end

When /^I sign in via the login page (as|with) "(.*?)"$/ do |_nothing, login_string|
  visit new_session_path
  When %{I fill in the login fields as "#{login_string}"}
  click_button 'Sign in'
end

When /^I sign in( as an admin)? via the login page( as an admin)?$/ do |is_admin_1, is_admin_2|
  is_admin = is_admin_1 || is_admin_2
  factory = is_admin ? :site_admin : :user
  user = Factory factory, :password => 'foobar', :password_confirmation => 'foobar'
  Then "I sign in via the login page as \"#{user.name}/foobar\""
end

When /^I am not logged in$/ do
  delete sign_out_path
end

When /^I check the remember\-me checkbox$/ do
  check "session[remember_me]"
end

Then /^I should( not)? see the session expiration message$/ do |sense|
  Then %{I should#{sense} see "Your session has expired. Please log back in to continue."}
end
