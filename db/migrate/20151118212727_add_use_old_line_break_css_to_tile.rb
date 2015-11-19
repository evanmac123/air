class AddUseOldLineBreakCssToTile < ActiveRecord::Migration
  def change
    add_column :tiles, :use_old_line_break_css, :boolean, default: false
  end
end
