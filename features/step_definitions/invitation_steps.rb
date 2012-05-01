When /^I invite "([^"]*)"$/ do |user_name|
  user = User.find_by_name(user_name)
  within("##{dom_id(user)}") do
    click_link "Invite"
  end
end

When /^"([^"]*)" has received an invitation$/ do |email|
  user = User.find_by_email(email)
  Mailer.invitation(user).deliver
end

When /^I accept the invitation$/ do
  phone = Factory.next(:phone)
  step "I fill in \"Enter your mobile number\" with \"#{phone}\""
  step "I fill in \"Choose a password\" with \"foobar\""
  step "I fill in \"And confirm that password\" with \"foobar\""
  step "I fill in \"Enter your name\" with \"foobar\""
  step "I press \"Join the game\""
end

When /^I fill in the required self-invitation fields$/ do
  step %{I fill in "Enter your name" with "Chester Humphries"}
  step %{I fill in "Choose a password" with "foobar"}
  step %{I fill in "And confirm that password" with "foobar"}
  step %{I fill in "Choose a username" with "chester"}
end
