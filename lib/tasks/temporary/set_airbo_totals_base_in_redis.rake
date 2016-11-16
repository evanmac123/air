namespace :admin do
  desc "set airbo totals base in redis"
  task set_airbo_totals: :environment do
    puts "Setting up redis for new keys..."
    [30, 60, 120, "current"].each { |key|
      $redis.hmset("reporting:airbo:percent_of_eligible_population_joined:#{key}", "percent", 0, "count", 0)
    }

    puts "Updating total paid organization count..."
    Reporting::ClientKPIsReport.set_total_paid_organizations

    puts "Updating total paid client admin count..."
    Reporting::ClientKPIsReport.set_total_paid_client_admins

    [30, 60, 120, "current"].each { |n|
      puts "Updating percent eligible users joined for #{n} days..."
      Reporting::ClientKPIsReport.set_percent_of_eligible_population_joined(n)
    }
  end
end

# rake admin:set_airbo_totals
