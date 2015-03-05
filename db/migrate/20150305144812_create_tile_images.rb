class CreateTileImages < ActiveRecord::Migration
  def change
    create_table :tile_images do |t|
      t.attachment :image
      t.attachment :thumbnail

      t.timestamps
    end
  end
end
