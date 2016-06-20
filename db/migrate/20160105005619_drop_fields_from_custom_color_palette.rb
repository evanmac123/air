class DropFieldsFromCustomColorPalette < ActiveRecord::Migration
  def up
    remove_column :custom_color_palettes, :primary_bg
    remove_column :custom_color_palettes, :primary_text
    remove_column :custom_color_palettes, :border_for_primary_filled_bg
    remove_column :custom_color_palettes, :border_for_white_filled_bg
  end

  def down
  end
end
