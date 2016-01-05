class RemoveTextForPrimaryFilledBgFromCustomColorPalette < ActiveRecord::Migration
  def up
    remove_column :custom_color_palettes, :text_for_primary_filled_bg
  end

  def down
    add_column :custom_color_palettes, :text_for_primary_filled_bg, :string
  end
end
