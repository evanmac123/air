class CreateSkins < ActiveRecord::Migration
  def self.up
    create_table :skins do |t|
      t.string :header_background_url
      t.string :nav_link_color
      t.string :active_nav_link_color
      t.string :logo_url
      t.string :play_now_button_url
      t.string :save_button_url
      t.string :see_more_button_url
      t.string :fan_button_url
      t.string :defan_button_url
      t.string :clear_button_url
      t.string :profile_link_color
      t.string :column_header_background_color
      t.string :victory_graphic_url
      t.string :points_color 
   
      t.belongs_to :demo
      t.timestamps
    end
  end

  def self.down
    drop_table :skins
  end
end
