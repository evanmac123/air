When /^I enter "([^"]*)" into the bonus points field$/ do |arg1|
  page.fill_in(:suggested_task_bonus_points, :with => arg1)
end

When /^I click "([^"]*)"$/ do |arg1|
page.click_button(:suggested_task_submit)
end
