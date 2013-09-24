class AddGetStartedLightboxDisplayedToUser < ActiveRecord::Migration
  def change
    add_column :users, :get_started_lightbox_displayed, :boolean
  end
end
