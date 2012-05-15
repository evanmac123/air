When /^DJ cranks( once)?( after a little while)?$/ do |_nothing, delay|
  step "DJ cranks 1 time#{delay}"
end

When /^DJ cranks (\d+) times?( after a little while)?$/ do |jobs_to_work_off, delay|
  if delay
    Timecop.travel(Time.now + 5.minutes)
  end

  Delayed::Worker.new.work_off(jobs_to_work_off.to_i)
end

When /^DJ works off( after a little while)?$/ do |delay|
  if delay
    Timecop.travel(Time.now + 5.minutes)
  end

  while (due_jobs = Delayed::Job.where("run_at <= ?", Time.now)).present?
    due_jobs.any?{|due_job| due_job.last_error.present?}.should be_false
    Delayed::Worker.new.work_off(10)
  end
end
