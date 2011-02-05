When /^I sign in via the login page as "(.*?)"$/ do |login_string|
  username, password = login_string.split('/')
  user = User.find_by_name(username)

  visit new_session_path
  fill_in 'session[email]', :with => user.email
  fill_in 'session[password]', :with => password
  click_button 'Sign in'
end
