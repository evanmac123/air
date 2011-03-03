When /^I debug$/ do
  debugger
end

When /^I dump the page$/ do
  puts page.body
end

When /^show me the cookies$/ do
  show_me_the_cookies
end

When /^I dump all SMSes$/ do
  puts FakeTwilio.sent_messages.inspect
end
