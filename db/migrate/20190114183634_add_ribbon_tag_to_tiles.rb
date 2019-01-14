class AddRibbonTagToTiles < ActiveRecord::Migration
  def change
    add_reference :tiles, :ribbon_tag, index: true, foreign_key: true
  end
end
