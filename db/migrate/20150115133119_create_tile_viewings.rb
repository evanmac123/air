class CreateTileViewings < ActiveRecord::Migration
  def up
    create_table :tile_viewings do |t|
      t.integer :tile_id
      t.integer :user_id
      t.string :user_type
      t.integer :views, default: 1

      t.timestamps
    end

    add_index :tile_viewings, [:tile_id, :user_id, :user_type], unique: true, name: "index_tile_viewings_on_tile_and_user"

    #TileCompletion.all.find_each do |tc|
      #TileViewing.create(tile: tc.tile, user: tc.user)
    #end
  end

  def down
    remove_index :tile_viewings, name: "index_tile_viewings_on_tile_and_user"
    drop_table :tile_viewings
  end
end
