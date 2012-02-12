Then /^I should see that I'm on level (\d+)$/ do |level_index|
  page.find(:css, ".bar_level .level").text.should == level_index.to_s
end
