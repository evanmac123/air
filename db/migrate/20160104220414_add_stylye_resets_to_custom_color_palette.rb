class AddStylyeResetsToCustomColorPalette < ActiveRecord::Migration
  def change
    add_column :custom_color_palettes, :enable_reset, :boolean
    add_column :custom_color_palettes, :content_background_reset, :string
    add_column :custom_color_palettes, :tile_progress_background_reset, :string
    add_column :custom_color_palettes, :tile_progress_all_tiles_text_reset, :string
    add_column :custom_color_palettes, :tile_progress_completed_tiles_text_reset, :string
  end
end
