namespace :admin do
  desc "set airbo totals base in redis"
  task set_airbo_totals: :environment do
    [30, 60, 120, "current"].each { |key|
      $redis.hmset("reporting:airbo:percent_of_eligible_population_joined:#{key}", "percent", 0, "count", 0)
    }

    Reporting::AirboTotals.set_total_paid_organizations
    Reporting::AirboTotals.set_total_paid_client_admins

    [30, 60, 120, "current"].each { |n|
      Reporting::AirboTotals.set_percent_of_eligible_population_joined(n)
    }
  end
end

# rake admin:set_airbo_totals
