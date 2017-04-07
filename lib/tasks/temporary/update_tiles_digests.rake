task :update_historical_digests => :environment do
  jql_script = %Q|function main() {return Events({from_date: "2013-03-05",to_date: "2017-03-28",event_selectors: [{event: "Digest - Sent"}]}).groupBy(["properties.game",mixpanel.numeric_bucket('time',mixpanel.daily_time_buckets)],mixpanel.reducer.count());}|

  puts "Getting data from Mixpanel"
  digest_data = mixpanel_client.request("jql", {script: jql_script})

  puts "Removing previous historical data..."
  TilesDigest.where("created_at < ?", Time.now - 1.week).destroy_all

  puts "Updating historical data..."
  digest_data.each { |digests_by_day|
    digests_by_day["value"].times do
      demo = Demo.find_by_id(digests_by_day["key"][0])

      if demo.nil?
        demo = Demo.find_by_name(digests_by_day["key"][0].to_s)
      end

      if demo.is_a?(Demo)
        puts "Adding TilesDigest for Demo #{demo.id}"
        t = TilesDigest.create(demo_id: demo.id)
        t.created_at = Time.at(digests_by_day["key"][1] / 1000.0)
        t.save
      end
    end
  }
end
