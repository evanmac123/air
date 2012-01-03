When /^I follow "([^"]*)" in the activity stream$/ do |link|
  When %{I follow "#{link}" within "#main .tabs"}
end

When /^I press the see more button in the activity stream$/ do
  find(:css, '#main #see-more').click
end
