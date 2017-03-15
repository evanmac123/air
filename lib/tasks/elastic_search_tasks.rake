task :elastic_search_daily_tasks => :environment do
  Campaign.reindex
end
