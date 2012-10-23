class NowStoringThumbnailSizesInDatabase < ActiveRecord::Migration
  def up
    add_column :tiles, :image_meta, :text
    add_column :tiles, :thumbnail_meta, :text
  end

  def down
    remove_columns :tiles, :image_meta, :thumbnail_meta
  end
end
