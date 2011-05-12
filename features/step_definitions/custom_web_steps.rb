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
