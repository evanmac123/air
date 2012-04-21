def user_suggestions(user_name, task_name)
  user = User.where(:name => user_name).first
  task = SuggestedTask.where(:name => task_name).first
  TaskSuggestion.where(:user_id => user.id, :task_id => task.id)
end

Given /^"([^"]*)" has completed task "([^"]*)"$/ do |user_name, task_name|
  suggestions = user_suggestions(user_name, task_name)
  suggestions.should_not be_empty
  suggestions.each(&:satisfy!)
end

Given /^"([^"]*)" has not had task "([^"]*)" suggested$/ do |user_name, task_name|
  user_suggestions(user_name, task_name).each(&:destroy)
end

When /^I enter "([^"]*)" into the bonus points field$/ do |arg1|
  page.fill_in(:task_bonus_points, :with => arg1)
end

When /^I click "([^"]*)"$/ do |arg1|
  page.click_button(:task_submit)
end
