def user_suggestions(user_name, task_name)
  user = User.where(:name => user_name).first
  task = Task.where(:name => task_name).first
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

Given /^the task "([^"]*)" has prerequisite "([^"]*)"$/ do |task_name, prerequisite_name|
  task = Task.where(:name => task_name).first
  prerequisite = Task.where(:name => prerequisite_name).first

  unless task
    raise ArgumentError.new "Couldn't find task named #{task_name}"
  end

  unless prerequisite
    raise ArgumentError.new "Couldn't find prerequisite task named #{prerequisite_name}"
  end

  task.prerequisite_tasks << prerequisite
end

When /^I set the task start time to "([^"]*)"$/ do |time_string|
  set_time_inputs("task_start_time", time_string)
end

When /^I click the link to edit the task "([^"]*)"$/ do |task_name|
  task_name_cell = page.find('td', :text => task_name)
  task_row_path = task_name_cell.path + '/..'
  within(:xpath, task_row_path) {click_link "Edit this task"}
end

When /^"([^"]*)" satisfies task "([^"]*)"$/ do |user_name, suggested_task_name|
  user = User.find_by_name(user_name)
  suggested_task = Task.find_by_name(suggested_task_name)

  suggestion = user.task_suggestions.where(:task_id => suggested_task.id).first
  suggestion.should_not be_nil

  suggestion.satisfied = true
  suggestion.save!
end
