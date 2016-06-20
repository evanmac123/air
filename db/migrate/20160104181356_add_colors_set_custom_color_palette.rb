class AddColorsSetCustomColorPalette < ActiveRecord::Migration
  def change
    add_column :custom_color_palettes, :primary_text, :string
    add_column :custom_color_palettes, :text_for_primary_filled_bg, :string
    add_column :custom_color_palettes, :primary_bg, :string
    add_column :custom_color_palettes, :border_for_primary_filled_bg, :string
    add_column :custom_color_palettes, :border_for_white_filled_bg, :string
  end

end
