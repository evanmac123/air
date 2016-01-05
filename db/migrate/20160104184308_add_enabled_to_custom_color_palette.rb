class AddEnabledToCustomColorPalette < ActiveRecord::Migration
  def change
    add_column :custom_color_palettes, :enabled, :boolean
  end
end
