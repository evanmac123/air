Given /^the task "([^"]*)" has prerequisite "([^"]*)"$/ do |task_name, prerequisite_name|
  task = SuggestedTask.where(:name => task_name).first
  prerequisite = SuggestedTask.where(:name => prerequisite_name).first

  unless task
    raise ArgumentError.new "Couldn't find task named #{task_name}"
  end

  unless prerequisite
    raise ArgumentError.new "Couldn't find prerequisite task named #{prerequisite_name}"
  end

  task.prerequisite_tasks << prerequisite
end

When /^I set the suggested task start time to "([^"]*)"$/ do |time_string|
  set_time_inputs("suggested_task_start_time", time_string)
end

When /^I click the link to edit the task "([^"]*)"$/ do |task_name|
  task_name_cell = page.find('td', :text => task_name)
  task_row_path = task_name_cell.path + '/..'
  within(:xpath, task_row_path) {click_link "Edit this task"}
end

When /^"([^"]*)" satisfies suggested task "([^"]*)"$/ do |user_name, suggested_task_name|
  user = User.find_by_name(user_name)
  suggested_task = SuggestedTask.find_by_name(suggested_task_name)

  suggestion = user.task_suggestions.where(:suggested_task_id => suggested_task.id).first
  suggestion.should_not be_nil

  suggestion.satisfied = true
  suggestion.save!
end
