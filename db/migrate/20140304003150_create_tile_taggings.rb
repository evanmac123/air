class CreateTileTaggings < ActiveRecord::Migration
  def change
    create_table :tile_taggings do |t|
      t.belongs_to :tile
      t.belongs_to :tile_tag
      t.timestamps
    end

    add_index :tile_taggings, :tile_id
    add_index :tile_taggings, :tile_tag_id
  end
end
