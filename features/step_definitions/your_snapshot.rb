def expect_your_score_contents(column, content)
  with_scope("\"#my-score .#{column}\"") do
    page.should have_content(content)
  end
end

Then /^I should see "([^"]*)" points$/ do |points|
  expect_your_score_contents('points', points)
end

Then /^I should see "([^"]*)" ranking$/ do |ranking|
  expect_your_score_contents('ranking', ranking)
end

Then /^I should see "(.*?)" in your snapshot table$/ do |content|
  Then "I should see \"#{content}\" within \"table#your-score\""
end

