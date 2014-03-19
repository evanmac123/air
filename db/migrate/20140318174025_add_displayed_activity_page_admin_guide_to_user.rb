class AddDisplayedActivityPageAdminGuideToUser < ActiveRecord::Migration
  def change
    add_column :users, :displayed_activity_page_admin_guide, :boolean, default: false    
    execute "UPDATE users SET displayed_activity_page_admin_guide = true"
  end
end
