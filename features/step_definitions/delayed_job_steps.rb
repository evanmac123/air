When /^DJ cranks( once)?( after a little while)?$/ do |_nothing, delay|
  When "DJ cranks 1 time#{delay}"
end

When /^DJ cranks (\d+) times?( after a little while)?$/ do |jobs_to_work_off, delay|
  if delay
    Timecop.travel(Time.now + 5.minutes)
  end

  Delayed::Worker.new.work_off(jobs_to_work_off.to_i)
end
