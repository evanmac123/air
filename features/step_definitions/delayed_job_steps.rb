When /^DJ cranks( once)?$/ do |_nothing|
  When "DJ cranks 1 time"
end

When /^DJ cranks (\d+) times?$/ do |jobs_to_work_off|
  Delayed::Worker.new.work_off(jobs_to_work_off.to_i)
end
