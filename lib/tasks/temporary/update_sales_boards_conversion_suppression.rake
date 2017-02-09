namespace :db do
  namespace :admin do
    desc "Update sales boards defaults"
    task update_sales_boards_defaults: :environment do
      sales_orgs = Organization.with_role(:sales).pluck(:id)
      sales_demos = Demo.joins(:organization).where(organization: { id: sales_orgs } ).pluck(:id)

      Demo.where(id: sales_demos).each { |d|
        d.guest_user_conversion_modal = false
        d.save
      }
    end
  end
end

# rake db:admin:update_sales_boards_defaults
