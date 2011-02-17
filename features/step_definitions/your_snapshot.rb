Then /^I should see "(.*?)" in your snapshot table$/ do |content|
  Then "I should see \"#{content}\" within \"table#your-score\""
end
