World(ShowMeTheCookies)

Before do
  $_real_start_time = Time.now # remembered here before Timecop gets to mess with it
  Factory :demo, :company_name => 'Alpha'
  Delayed::Job.delete_all
end

After do
  Timecop.return
end

scenario_times = {}

Around() do |scenario, block|
  block.call
  scenario_times["#{scenario.feature.file}::#{scenario.name}"] = Time.now - $_real_start_time
end

at_exit do
  timestamp = Time.now.strftime("%Y_%m_%d_%H%M")
  filename = "feature_profiles/feature_profile-#{timestamp}"
  puts "Writing feature profile information to #{filename}"

  File.open filename, "w" do |f|
    sorted_times = scenario_times.sort { |a, b| b[1] <=> a[1] }
    sorted_times.each do |key, value|
      f.puts "#{value.round(2)}  #{key}"
    end
  end
end

