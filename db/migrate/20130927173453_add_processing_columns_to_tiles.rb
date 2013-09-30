class AddProcessingColumnsToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :image_processing, :boolean
    add_column :tiles, :thumbnail_processing, :boolean
  end
end
