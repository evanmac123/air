namespace :admin do
  desc "Cleanup sales leads"
  task sales_leads: :environment do
    ["eamonn.culliton@airbo.com", "marco.schneiderman@airbo.com"].each { |admin|
      admin = User.find_by_email(admin)
      all_leads = Organization.rdb[:sales][:leads].smembers
      all_leads.each { |lead|
        user = User.find_by_id(lead)
        if user && user.organization
          org = user.organization
          puts "Adding #{org.name} as lead in Redis"
          Organization.rdb[:sales][:active_orgs_in_sales].sadd(org.id)
          if admin.rdb[:sales][:leads].smembers.include?(lead)
            puts "Adding #{org.name} as #{admin.name}'s lead in Redis"
            admin.rdb[:sales][:active_orgs_in_sales].sadd(org.id)
          end
        end
      }
    }
  end
end
