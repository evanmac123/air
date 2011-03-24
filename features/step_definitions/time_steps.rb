When /^time is frozen at "(.*?)"$/ do |time_string|
  time = Time.parse(time_string)
  Timecop.freeze(time)
end

When /^time is frozen$/ do
  Timecop.freeze(Time.parse('2010-01-01 00:00:00 UTC'))
end

When /^time is unfrozen$/ do
  Timecop.return
end
