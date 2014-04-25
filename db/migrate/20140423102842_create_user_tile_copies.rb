class CreateUserTileCopies < ActiveRecord::Migration
  def up
    create_table :user_tile_copies do |t|
      t.belongs_to :tile
      t.belongs_to :user
      t.timestamps
    end
    add_index :user_tile_copies, :tile_id
    add_index :user_tile_copies, :user_id
  end

  def down
    drop_table :user_tile_copies
  end
end
