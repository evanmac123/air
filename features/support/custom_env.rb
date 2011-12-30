World(ShowMeTheCookies)

Before do
  Factory :demo, :company_name => 'Alpha'
  Delayed::Job.delete_all
end

After do
  Timecop.return
end
