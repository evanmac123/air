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


task :update_follow_ups => :environment do
  jql_script = %Q|function main() { return Events({ from_date: "2013-03-05", to_date: "2017-04-25", event_selectors: [{ event: "Digest - Sent", selector: `properties["followup_scheduled"] == true` }] }).groupBy(["properties.game",mixpanel.numeric_bucket('time',mixpanel.daily_time_buckets)],mixpanel.reducer.count());}|

  puts "Getting data from Mixpanel"
  digest_data = $mixpanel_client.request("jql", {script: jql_script})

  puts "Updating historical data..."
  digest_data.each { |digests_by_day|
    digests_by_day["value"].times do
      demo = Demo.find_by_id(digests_by_day["key"][0])

      if demo.nil?
        demo = Demo.find_by_name(digests_by_day["key"][0].to_s)
      end

      if demo.is_a?(Demo)
        puts "Adding FollowUpDigestEmail for Demo #{demo.id}"
        tiles_digest = TilesDigest.where(demo_id: demo.id).where(created_at: Time.at(digests_by_day["key"][1] / 1000.0)).first

        if tiles_digest.present?
          follow_up = tiles_digest.create_follow_up_digest_email(sent: true, send_on: tiles_digest.created_at.to_date + 3.days)

          tiles_digest.update_attributes(followup_delivered: true)
          follow_up.created_at = tiles_digest.created_at
          follow_up.save
        end
      end
    end
  }
end
