namespace :admin do
  desc "Cleanup sales leads"
  task sales_orgs: :environment do
    ["eamonn-admin@airbo.com", "marco-admin@airbo.com"].each { |admin|
      redis_orgs = admin.rdb[:sales][:active_orgs_in_sales].smembers
      orgs = Organization.where(id:  redis_orgs)

      orgs.each do |o|
        admin.add_role(:sales, o)
      end
    }
  end
end
