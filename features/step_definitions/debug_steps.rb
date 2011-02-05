When /^I debug$/ do
  debugger
end

When /^I dump the page$/ do
  puts page.body
end

When /^show me the cookies$/ do
  show_me_the_cookies
end
