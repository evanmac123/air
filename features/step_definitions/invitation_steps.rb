When /^I invite "([^"]*)"$/ do |player_name|
  player = Player.find_by_name(player_name)
  within("##{dom_id(player)}") do
    click_link "Invite"
  end
end

Then /^"([^"]*)" should receive an invitation email to "([^"]*)"$/ do |email, name|
  demo = Demo.find_by_company_name(name)
end
