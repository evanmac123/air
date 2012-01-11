Then /^we should have recorded that "([^"]*)" suggested "([^"]*)"$/ do |username, suggestion_text|
  user = User.find_by_name(username)
binding.pry
  Suggestion.where(:user_id => user.id, :value => suggestion_text).first.should_not be_nil
end

Then /^we should not have recorded any suggestions$/ do
  Suggestion.count.should == 0
end
