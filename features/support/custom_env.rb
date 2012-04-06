World(ShowMeTheCookies)

Before do
  $_real_start_time = Time.now # remembered here before Timecop gets to mess with it
  Factory :demo, :name => 'Alpha'
  Delayed::Job.delete_all
end

After do
  Timecop.return
end

# Get Steak helpers too, to help us gradually transition from Cucumber to Steak
Dir["#{::Rails.root.to_s}/spec/acceptance/support/**/*.rb"].each {|f| require f}
World(SteakHelperMethods)
