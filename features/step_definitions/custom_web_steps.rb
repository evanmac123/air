# This file is for utility steps about the rendered output, things that would 
# not be out of place in web_steps.rb. We don't want to edit that file
# directly, so here we are.

# Overwriting the contents of a text field that we find by its current content
When /^I replace "([^"]*)" with "([^"]*)"$/ do |old_value, new_value|
  text_field = page.find(:css, "input[value='#{old_value}']")
  text_field.should_not be_nil
  fill_in text_field['name'], :with => new_value
end

When /^I set the datetime selector for "(.*?)" to "(.*?)"$/ do |prefix, date_string|
  year, month, day, time = date_string.split
  hour, minute = time.split(/:/)
  _prefix = prefix.gsub(/\s+/, '_')
  # This isn't great code, but it works, and how much time is it worth 
  # spending on this?
  select year, :from => "#{_prefix}[year]"
  select month, :from => "#{_prefix}[month]"
  select day, :from => "#{_prefix}[day]"
  select hour, :from => "#{_prefix}[hour]"
  select minute, :from => "#{_prefix}[minute]"
end

When /^I press the button to submit the mobile number$/ do
  page.find(:css, "form[@action='/account/phone'] input[@type=image]").click
end

When /^I press the button to submit a new unique ID$/ do
  page.find(:css, "form[@action='/account/sms_slug'] input[@type=image]").click
end

When /^I press the button to update follow notification status$/ do
  page.find(:css, "form.text-settings input[@type=image]").click
end

When /^I press the button to update follow notification status$/ do
  page.find(:css, "form.text-settings input[@type=image]").click
end

When /^I press the button to submit a new name$/ do
  page.find(:css, "#save-name").click
end

When /^I press the fan button$/ do
  find(:css, '.be-a-fan').click
end

When /^I press the de\-fan button$/ do
  find(:css, '.defan').click
end

When /^(?:|I )unselect "([^"]*)" from "([^"]*)"(?: within ("[^"]*"))?$/ do |value, field, selector|
  with_scope(selector) do
    unselect(value, :from => field)
  end
end

Then /^(?:|I )should see `([^`]*)`(?: within ("[^"]*"))?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end

Then /^I should see "(.*?)" within a link to (.*?)$/ do |text, page_name|
  expected_href = path_to(page_name)

  with_scope("\"a[href='#{expected_href}']\"") do
    page.should have_content(text)
  end
end

Then /^I should see "(.*?)" in that order$/ do |text|
  text_fragments = text.split(',')
  regex_body = text_fragments.join('.*')
  page.body.should match(/#{regex_body}/m)
end

Then /^I should (not )?see a link to (.*)$/ do |sense, page_name|
  sense = !sense

  expected_path = path_to page_name

  if sense
    page.should have_css("a[href=\"#{expected_path}\"]")
  else
    page.should_not have_css("a[href=\"#{expected_path}\"]")
  end
end

Then /^I should see "(.*?)" just once$/ do |text|
  normalized_body = page.all(:xpath, "/html[contains(normalize-space(.),'#{text}')]").first.text
  quoted_text = Regexp.escape(text)

  match_first_time = (normalized_body.match(quoted_text))
  match_first_time.should_not be_nil

  match_second_time = (match_first_time.post_match.match(quoted_text))
  match_second_time.should be_nil
end

Then /^"(.*?)" should be disabled$/ do |input_text|
  page.find(:css, "input[value='#{input_text}'][disabled='disabled']").should_not be_nil
end

Then /^I should see a restricted text field "([^"]*)" with length (\d+)$/ do |locator, length|
  field = page.find_field(locator)
  field.should_not be_nil
  field['maxlength'].should == length
end

Then /^I should see a restricted text field "([^"]*)"$/ do |selector|
  Then "I should see a restricted text field \"#{selector}\" with length 160"
end

Then /^I should see '(.*?)'$/ do |expected_text|
  page.should have_content(expected_text)
end

Then /^(?:|I )should not be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  current_path.should_not == path_to(page_name)
end

Then /^"(.*?)" should( not)? be visible$/ do |invisible_text, sense|
  sense = !sense

  elements = page.all(:css, "*", :text => invisible_text)

  if sense
    elements.should_not be_empty
    elements.each{|element| element.should be_visible}
  else
    elements.each{|element| element.should_not be_visible}
  end
end

Then /^I should( not)? see an input with value "([^"]*)"$/ do |sense, expected_value|
  sense = !sense

  if sense
    page.should have_css("input[value=\"#{expected_value}\"]")
  else
    page.should_not have_css("input[value=\"#{expected_value}\"]")
  end
end

When /^I should not see a form field called "([^"]*)"$/ do |field_name|
  # Yeah, it's a hack. Shut up.
  begin
    find_field(field_name)
    raise "field found but not expected to"
  rescue Capybara::ElementNotFound
  end
end

