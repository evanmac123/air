class AddPrimaryColorToCustomColorPalette < ActiveRecord::Migration
  def change
    add_column :custom_color_palettes, :primary_color, :string
  end
end
