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
