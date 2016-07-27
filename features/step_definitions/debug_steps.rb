When /^I debug$/ do
  debugger
end

When /^I pry$/ do
  binding.pry
end
``
When /^I dump the page$/ do
  puts page.body
end

When /^show me the cookies$/ do
  show_me_the_cookies
end

When /^I dump all( sent)? (texts|SMSes)$/ do |_nothing1, _nothing2|
  dump_sent_texts
end
