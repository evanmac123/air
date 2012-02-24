When /^I follow "([^"]*)" in the activity stream$/ do |link|
  When %{I follow "#{link}" within "#main .tabs"}
end

When /^I press the see more button in the activity stream$/ do
  find(:css, 'div.seemore #see-more').click
end

When /^I apply the filter to see only my acts$/ do
  click_link "Mine"
end

When /^I apply the filter to see all acts$/ do
  click_link "All"
end

