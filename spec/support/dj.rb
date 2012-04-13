def crank_dj(iterations=1)
  Delayed::Worker.new.work_off(iterations)
end

def crank_dj_clear
  while (due_jobs = Delayed::Job.where("run_at <= ?", Time.now)).present?
    due_jobs.any?{|due_job| due_job.last_error.present?}.should be_false
    Delayed::Worker.new.work_off(10)
  end
end
