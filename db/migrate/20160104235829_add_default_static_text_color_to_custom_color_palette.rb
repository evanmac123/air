class AddDefaultStaticTextColorToCustomColorPalette < ActiveRecord::Migration
  def change
    add_column :custom_color_palettes, :static_text_color, :string
  end
end
