def expect_src(selector, expected_src)
  matching_elements = all(:css, selector)
  matching_elements.should_not be_empty

  matching_elements.each do |matching_element|
    matching_element['src'].gsub(/\?.*$/, '').should == "/images/#{expected_src}"
  end
end

def expect_no_style(selector, unexpected_style_key)
  all(:css, selector).each do |matching_element|
    next unless (raw_style = matching_element['style'])
    pending
    #style_attributes = raw_style.split(/;/).map(&:strip)
  end
end

Then /^the logo graphic should have src "([^"]*)"$/ do |expected_src|
  expect_src("#logo img", expected_src)
end

Then /^the play now button graphic should have src "([^"]*)"$/ do |expected_src|
  expect_src("#add-action input[type=image]", expected_src)
end

Then /^the see more button graphics should have src "([^"]*)"$/ do |expected_src|
  expect_src("input#see-more, input#show-all-ranked-players", expected_src)
end

Then /^save button graphics should have src "([^"]*)"$/ do |expected_src|
  expect_src("#save-phone, #save-avatar, #save-username, #save-text-settings", expected_src)
end

Then /^the victory graphics should have src "([^"]*)"$/ do |expected_src|
  expect_src(".top-scores img", expected_src)
end

Then /^fan button graphics should have src "([^"]*)"$/ do |expected_src|
  expect_src(".be-a-fan", expected_src)
end

Then /^de\-fan button graphics should have src "([^"]*)"$/ do |expected_src|
  expect_src(".defan", expected_src)
end

Then /^the header background should have no element graphic$/ do
  expect_no_style('div.header', 'background')
end


Then /^the nav links should have no element color$/ do
  expect_no_style('div.inner-header a', 'color')
end

Then /^the active nav link should have no element color$/ do
  expect_no_style('div.inner-header a.current-section', 'color')
end

Then /^profile links should have no element color$/ do
  expect_no_style('.act-details .user a, .top-scores a .name', 'color')
end

Then /^activity feed points should have no element color$/ do
  expect_no_style('.act-details .points .point-value', 'color')
end

Then /^scoreboard points should have no element color$/ do
  expect_no_style('.top-scores .score', 'color')
end

Then /^column headers should have no element color$/ do
  expect_no_style('#secondary h2', 'color')
end
