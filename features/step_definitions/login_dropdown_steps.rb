When /^I press the button to activate the login dropdown$/ do
  find(:css, "#activate-login-form input[type=image]").click
end

When /^I fill in the login dropdown email field with "([^"]*)"$/ do |email|
  find(:css, "#login-form input[type=text]").set(email)
end

When /^I fill in the login dropdown password field with "([^"]*)"$/ do |password|
  find(:css, "#login-form input[type=password]").set(password)
end

When /^I press the "go" button in the login dropdown$/ do
  find(:css, "#login-form input[type=image]").click
end


