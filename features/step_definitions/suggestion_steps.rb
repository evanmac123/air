require 'spec/acceptance/acceptance_helper'
Cucumber::Rails::World.send(:include, HelperMethods)

Then /^we should have recorded that "([^"]*)" suggested "([^"]*)"$/ do |username, suggestion_text|
  assert_suggestion_recorded(username, suggestion_text)
end

Then /^we should not have recorded any suggestions$/ do
  Suggestion.count.should == 0
end
