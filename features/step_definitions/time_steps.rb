When /^time is frozen at "(.*?)"$/ do |time_string|
  time = Time.parse(time_string)
  Timecop.freeze(time)
end

When /^time is unfrozen$/ do
  Timecop.return
end
