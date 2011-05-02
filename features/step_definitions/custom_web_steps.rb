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
