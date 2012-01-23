def master_bar_selector
  '.mast_bottom .bar .progress'
end

Then /^the master bar should show ([\d.]+%) complete$/ do |percentage|
  Then %{"#{master_bar_selector}" should have inline style "width" set to "#{percentage}"}
end

Then /^the master bar should show (\d+) points$/ do |point_value|
  expected_phrase = (point_value.to_i == 1 ? '1pt' : "#{point_value}pts")
  find(:css, master_bar_selector).text.should == expected_phrase
end

