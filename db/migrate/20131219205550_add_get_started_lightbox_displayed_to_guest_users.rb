class AddGetStartedLightboxDisplayedToGuestUsers < ActiveRecord::Migration
  def change
    add_column :guest_users, :get_started_lightbox_displayed, :boolean
  end
end
