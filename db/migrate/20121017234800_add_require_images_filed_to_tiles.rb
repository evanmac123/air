class AddRequireImagesFiledToTiles < ActiveRecord::Migration
  def up 
    add_column :tiles, :require_images, :boolean, :null => false, :default => true 
  end

  def down
    remove_columns :tiles, :require_images
  end
end
