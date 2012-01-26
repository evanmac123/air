World(ShowMeTheCookies)

Before do
  $_real_start_time = Time.now # remembered here before Timecop gets to mess with it
  Factory :demo, :name => 'Alpha'
  Delayed::Job.delete_all
end

After do
  Timecop.return
end
