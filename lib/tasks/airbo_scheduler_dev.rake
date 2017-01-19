desc "Mock Heroku scheduler in dev"
task airbo_scheduler_dev: :environment do
  scheduler_tasks = [
    "cron",
    "reports:client_admin:weekly_activity",
    "admin:reports:financials:build_daily",
    "admin:reports:customer_success:build_daily",
    "organization_stats_in_redis"
  ]

  scheduler_tasks.each do |task|
    Rake::Task[task].invoke
  end
end
