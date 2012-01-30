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

When /^I select the suggestion containing "([^"]*)"$/ do |arg1|
  page.find(:css, ".single_suggestion:contains('#{arg1}')").click
end

When /^I press the button to submit the mobile number$/ do
  page.find(:css, "form[@action='/account/phone'] input[@type=image]").click
end

When /^I press the button to submit a new unique ID$/ do
  page.find(:css, "form[@action='/account/sms_slug'] input[@type=submit]").click
end

When /^I press the button to update follow notification status$/ do
  page.find(:css, "form.text-settings input[@type=image]").click
end

When /^I press the button to update follow notification status$/ do
  page.find(:css, "form.text-settings input[@type=image]").click
end

When /^I press the button to save the user's settings$/ do
  page.find(:css, "form[@action=\"#{account_settings_path}\"] input[@type=submit]").click
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

When /^I fill in "([^"]*)" with the following:$/ do |locator, string|
  fill_in locator, :with => string
end

When /^I select "([^"]*)" from the feet select$/ do |value|
  select value, :from => 'height_feet'
end

When /^I select "([^"]*)" from the inches select$/ do |value|
  select value, :from => 'height_inches'
end

When /^I press the button to save notification settings$/ do
  find(:css, '#save-notification-settings').click
end

When /^I press the sign-in button$/ do
  When %{I press "Let's play!"}
end

Then /^the feet select should have "([^"]*)" selected$/ do |value|
  selected_option = find(:css, "#height_feet option[@selected=selected]")
  selected_option['value'].to_s.should == value
end

Then /^the inches select should have "([^"]*)" selected$/ do |value|
  selected_option = find(:css, "#height_inches option[@selected=selected]")
  selected_option['value'].to_s.should == value
end

Then /^the feet select should have nothing selected$/ do
  all(:css, "#height_feet option[@selected=selected]").should be_empty
end

Then /^the inches select should have nothing selected$/ do
  all(:css, "#height_inches option[@selected=selected]").should be_empty
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

Then /^"([^"]*)" should have value "([^"]*)"$/ do |locator, expected_value|
  field = page.find_field(locator)
  field.value.to_s.should == expected_value
end

Then /^"([^"]*)" should have "([^"]*)" selected$/ do |locator, expected_text|
  field = page.find_field(locator)
  selected_option = field.find("option[@selected=selected]")
  selected_option.text.should == expected_text
end

Then /^"([^"]*)" should have nothing selected$/ do |locator|
  field = page.find_field(locator)
  field.all("option[@selected=selected]").should be_empty
end

Then /^I should not see a form field called "([^"]*)"$/ do |field_name|
  # Yeah, it's a hack. Shut up.
  begin
    find_field(field_name)
    raise "field #{field_name} found but not expected to"
  rescue Capybara::ElementNotFound
  end
end

When /^I wait a second$/ do
  sleep 1
end

When /^I press the button to save privacy settings$/ do
  find(:css, ".privacy_settings input[type=submit]").click
end

When /^I close the modal window$/ do
  page.execute_script %{$(document).trigger('close.facebox');}
end

Then /^user with email "([^"]*)" should show up as referred by "([^"]*)"$/ do |email, name_passed_in|
  new_user = User.where(:email => email).first
  referrer = new_user.game_referrer
  raise "name does not match" unless referrer.name == name_passed_in
end

Then /^"([^"]*)" should be chosen$/ do |expected_checked_field|
  page.should have_checked_field(expected_checked_field)
end


Then /^(I should see|there should be) a mail link to support in the status area$/ do |_nothing|
  find(:css, %{.status a[@href="mailto:support@hengage.com"]}).should_not be_nil
end

Given /^the demo for "([^"]*)" starts tomorrow$/ do |arg1|
  a = Demo.find_by_name(arg1)
  a.begins_at = 1.day.from_now.to_date
  a.ends_at = 12.days.from_now.to_date
  a.save
end

Then /^I should see "([^"]*)" in a facebox modal$/ do |arg1|
  page.find('#facebox').should have_content (arg1)
end

Then /^I should not see a facebox modal$/ do
 page.should_not have_selector('#facebox')
end

Then /^there should be a user with email "([^"]*)" in demo "([^"]*)"$/ do |email, name|
  demo_id = Demo.find_by_name(name).id
  User.where(:email => email, :demo_id => demo_id).should_not be_empty
end
