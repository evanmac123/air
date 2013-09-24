class AddGetStartedLightboxDisplayedToUser < ActiveRecord::Migration
  def up
    add_column :users, :get_started_lightbox_displayed, :boolean
    execute "UPDATE users SET get_started_lightbox_displayed=sample_tile_completed"
  end

  def down
    remove_column :users, :get_started_lightbox_displayed
  end
end
