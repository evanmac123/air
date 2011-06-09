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

When /^time moves ahead (.*?)$/ do |advancement|
  advancement_parts = advancement.split(':').map(&:to_i)
  case advancement_parts.length
  when 1
    _minutes = advancement_parts[0]
    _hours = 0
    _seconds = 0
  when 2
    _minutes, _seconds = advancement_parts
    _hours = 0
  when 3
    _hours, _minutes, _seconds = advancement_parts
  end

  Timecop.freeze(Time.now + _hours.hours + _minutes.minutes + _seconds.seconds)
end
