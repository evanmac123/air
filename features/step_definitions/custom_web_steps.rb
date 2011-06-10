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

Then /^(?:|I )should see `([^`]*)`(?: within "([^"]*)")?$/ do |text, selector|
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

  with_scope("a[href='#{expected_href}']") do
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
