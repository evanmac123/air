When /^I sign in via the login page as "(.*?)"$/ do |login_string|
  username, password = login_string.split('/')
  user = User.find_by_name(username)

  visit new_session_path
  fill_in 'session[email]', :with => user.email
  fill_in 'session[password]', :with => password
  click_button 'Sign in'
end

When /^I sign in via the login page$/ do
  user = Factory :user, :password => 'foo', :password_confirmation => 'foo'
  Then "I sign in via the login page as \"#{user.name}/foo\""
end

When /^I am not logged in$/ do
  delete sign_out_path
end

Given /^"(.*?)" has the password "(.*?)"$/ do |username, new_password|
  user = User.find_by_name(username)
  user.password = user.password_confirmation = new_password
  user.save!
end
