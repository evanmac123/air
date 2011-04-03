def expect_your_score_contents(row, column, content)
  with_scope("#your-score tr##{row} .#{column}") do
    page.should have_content(content)
  end
end

Then /^I should see "([^"]*)" alltime points$/ do |points|
  expect_your_score_contents('alltime', 'points', points)
end

Then /^I should see "([^"]*)" alltime ranking$/ do |ranking|
  expect_your_score_contents('alltime', 'ranking', ranking)
end

Then /^I should see "([^"]*)" recent average points$/ do |points|
  expect_your_score_contents('recent-average', 'points', points)
end

Then /^I should see "([^"]*)" recent average ranking$/ do |ranking|
  expect_your_score_contents('recent-average', 'ranking', ranking)
end

Then /^I should see "(.*?)" in your snapshot table$/ do |content|
  Then "I should see \"#{content}\" within \"table#your-score\""
end

