# General

Then /^I should see error messages$/ do
  step %{I should see "errors prohibited"}
end

Then /^I should see an error message$/ do
  step %{I should see "error prohibited"}
end

# Database

Given /^no user exists with an email of "(.*)"$/ do |email|
  assert_nil User.find_by_email(email)
end

Given /^I signed up with "(.*)\/(.*)"$/ do |email, password|
  FactoryGirl.create(:user,
          :email                 => email,
          :password              => password,
          :password_confirmation => password)
end

Given /^I am a claimed user who signed up with "(.*)\/(.*)"$/ do |email, password|
  FactoryGirl.create(:claimed_user, :email                 => email,
                                    :password              => password,
                                    :password_confirmation => password)
end

Given /^I am signed up as "([^"]+)"$/ do |email_password|
  step %{I signed up with "#{email_password}"}
end

# Session

Then /^I should be signed in$/ do
  step %{I am on the homepage}
  step %{I should see "Sign Out"}
end

Then /^I should be signed out$/ do
  step %{I am on the homepage}
  expect_marketing_page_blurb
end

When /^session is cleared$/ do
  # TODO: This doesn't work with Capybara
  # TODO: I tried Capybara.reset_sessions! but that didn't work
  #request.reset_session
  #controller.instance_variable_set(:@_current_user, nil)
end

Given /^I have signed in with "(.*)\/(.*)"$/ do |email, password|
  Given %{I am signed up as "#{email}/#{password}"}
  step %{I sign in as "#{email}/#{password}"}
end

Given /^I sign in$/ do
  email = FactoryGirl.generate(:email)
  Given %{I have signed in with "#{email}/password"}
end

# Emails

Then /^a password reset message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  assert !user.confirmation_token.blank?
  assert (mailbox_for(email).size > 0)
  result = mailbox_for(email).any? do |email|
    email.to == [user.email] &&
    email.subject =~ /password/i &&
    email.body =~ /#{user.confirmation_token}/
  end
  assert result
end

When /^I follow the password reset link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  visit edit_user_password_path(:user_id => user,
                                :token   => user.confirmation_token)
end

When /^I try to change the password of "(.*)" without token$/ do |email|
  user = User.find_by_email(email)
  visit edit_user_password_path(:user_id => user)
end

Then /^I should be forbidden$/ do
  assert_response :forbidden
end

# Actions

When /^I sign in as "(.*)\/(.*)"$/ do |email, password|
  step %{I go to the sign in page}
  step %{I fill in "session[email]" with "#{email}"}
  step %{I fill in "session[password]" with "#{password}"}
  step %{I press the sign-in button}
end

When "I sign out" do
  step %{I go to the homepage}
  step %{I follow "Sign Out"}
end

When /^I request password reset link to be sent to "(.*)"$/ do |email|
  step %{I go to the password reset request page}
  step %{I fill in the reset email field with "#{email}"}
  step %{I press "Reset password"}
end

When /^I update my password with "(.*)\/(.*)"$/ do |password, confirmation|
  step %{I fill in "Password" with "#{password}"}
  step %{I fill in "Confirm password" with "#{confirmation}"}
  step %{I press "Save this password"}
end

When /^I return next time$/ do
  step %{session is cleared}
  step %{I go to the homepage}
end

When /^I fill in the reset email field with "([^"]*)"$/ do |email|
  step %{I fill in "password[email]" with "#{email}"}
end
