class AddSeeingMarketingPageForFirstTimeToGuestUsers < ActiveRecord::Migration
  def change
    add_column :guest_users, :seeing_marketing_page_for_first_time, :boolean, default: true
    execute "UPDATE guest_users SET seeing_marketing_page_for_first_time = false"
  end
end
