class CreateTileMedia < ActiveRecord::Migration
  def change
    create_table :tile_media do |t|
      t.references :tile
      t.attachment :document
      t.string :remote_url
      t.boolean :processed

      t.timestamps
    end
    add_index :tile_media, :tile_id
  end
end
