When /^I follow "([^"]*)" within the activity stream$/ do |link|
  When %{I follow "#{link}" within "#main .tabs"}
end

When /^I press the see more button within the activity stream$/ do
  find(:css, '#main #see-more').click
end
