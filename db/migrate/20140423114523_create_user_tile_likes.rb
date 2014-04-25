class CreateUserTileLikes < ActiveRecord::Migration
  def up
    create_table :user_tile_likes do |t|
      t.belongs_to :tile
      t.belongs_to :user
      t.timestamps
    end
    add_index :user_tile_likes, [:tile_id, :user_id], unique: true
    add_index :user_tile_likes, :user_id
  end

  def down
    drop_table :user_tile_likes
  end
end
